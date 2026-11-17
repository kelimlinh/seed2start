param(
  [string]$ProjectRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
$utf8 = New-Object System.Text.UTF8Encoding($false)
[Console]::OutputEncoding = $utf8
$OutputEncoding = $utf8

function Read-Utf8([string]$path) {
  return [System.IO.File]::ReadAllText($path, $utf8)
}

function Add-Line(
  [System.Collections.Generic.List[string]]$lines,
  [string]$text = ""
) {
  $lines.Add($text) | Out-Null
}

function Add-Check(
  [System.Collections.Generic.List[string]]$lines,
  [string]$status,
  [string]$label,
  [string]$detail
) {
  Add-Line $lines ("[{0}] {1}" -f $status, $label)
  if ($detail) {
    Add-Line $lines ("    {0}" -f $detail)
  }
}

function Relative-Path([string]$base, [string]$path) {
  $baseUri = New-Object System.Uri(($base.TrimEnd('\') + '\'))
  $pathUri = New-Object System.Uri($path)
  return [System.Uri]::UnescapeDataString(
    $baseUri.MakeRelativeUri($pathUri).ToString().Replace('/', '\')
  )
}

$projectRoot = (Resolve-Path $ProjectRoot).Path
$pubspec = Join-Path $projectRoot "pubspec.yaml"

if (-not (Test-Path $pubspec)) {
  throw "pubspec.yaml not found. Run from psycapnote_website project root."
}

$reportDir = Join-Path $projectRoot "release_reports"
New-Item -ItemType Directory -Force -Path $reportDir | Out-Null
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportPath = Join-Path $reportDir "release_audit_$timestamp.txt"

$lines = New-Object 'System.Collections.Generic.List[string]'

Add-Line $lines "WEBSITE HƯỚNG DẪN KHỞI NGHIỆP CÙNG MẦM"
Add-Line $lines "PHASE 10B — LOCAL RELEASE AUDIT"
Add-Line $lines ("Generated: {0}" -f (Get-Date))
Add-Line $lines ("Project: {0}" -f $projectRoot)
Add-Line $lines ""
Add-Line $lines "Legend: PASS = good, REVIEW = inspect, FAIL = should fix before release."
Add-Line $lines ""

# -------------------------------------------------------------------
# 1. Required structure
# -------------------------------------------------------------------
Add-Line $lines "============================================================"
Add-Line $lines "1. REQUIRED PROJECT STRUCTURE"
Add-Line $lines "============================================================"

$required = @(
  "lib",
  "functions/index.js",
  "functions/package.json",
  "web/index.html",
  "pubspec.yaml",
  "firebase.json",
  "firestore.rules"
)

foreach ($relative in $required) {
  $path = Join-Path $projectRoot $relative
  if (Test-Path $path) {
    Add-Check $lines "PASS" $relative "Present."
  } else {
    Add-Check $lines "FAIL" $relative "Missing."
  }
}

# -------------------------------------------------------------------
# 2. Branding sweep
# -------------------------------------------------------------------
Add-Line $lines ""
Add-Line $lines "============================================================"
Add-Line $lines "2. BRANDING SWEEP"
Add-Line $lines "============================================================"

$scanRoots = @(
  (Join-Path $projectRoot "lib"),
  (Join-Path $projectRoot "web"),
  (Join-Path $projectRoot "functions")
)

$scanFiles = New-Object 'System.Collections.Generic.List[System.IO.FileInfo]'
foreach ($scanRoot in $scanRoots) {
  if (-not (Test-Path $scanRoot)) { continue }

  Get-ChildItem -LiteralPath $scanRoot -Recurse -File |
    Where-Object {
      $_.FullName -notmatch '[\\/](node_modules|build|\.dart_tool|\.firebase|coverage)[\\/]' -and
      $_.Extension -in @(".dart", ".js", ".json", ".html", ".yaml", ".yml")
    } |
    ForEach-Object { $scanFiles.Add($_) | Out-Null }
}

$oldBrandHits = New-Object 'System.Collections.Generic.List[string]'
$technicalBrandHits = New-Object 'System.Collections.Generic.List[string]'
$placeholderHits = New-Object 'System.Collections.Generic.List[string]'

function Is-KnownTechnicalBrandUse([string]$relative, [string]$row) {
  if ($row -match 'PsyCapNoteApp') { return $true }
  if ($row -match 'psycapnote-media-') { return $true }
  if ($row -match '"name"\s*:\s*"psycapnote-functions"') { return $true }
  return $false
}

foreach ($file in $scanFiles) {
  try {
    $content = Read-Utf8 $file.FullName
  } catch {
    continue
  }

  $relative = Relative-Path $projectRoot $file.FullName
  $rows = $content -split "`r?`n"

  for ($i = 0; $i -lt $rows.Length; $i++) {
    $row = $rows[$i]

    if ($row -match 'PsyCapNote|PsyCap Note') {
      $hit = ("{0}:{1}: {2}" -f $relative, ($i + 1), $row.Trim())
      if (Is-KnownTechnicalBrandUse $relative $row) {
        $technicalBrandHits.Add($hit) | Out-Null
      } else {
        $oldBrandHits.Add($hit) | Out-Null
      }
    }

    if (
      $row -match 'A new Flutter project' -or
      $row -match '<title>psycapnote_website</title>' -or
      $row -match 'apple-mobile-web-app-title.*psycapnote_website'
    ) {
      $placeholderHits.Add(
        ("{0}:{1}: {2}" -f $relative, ($i + 1), $row.Trim())
      ) | Out-Null
    }
  }
}

if ($oldBrandHits.Count -eq 0) {
  Add-Check $lines "PASS" "User-facing legacy brand search" "No non-technical PsyCapNote/PsyCap Note occurrence found."
} else {
  Add-Check $lines "REVIEW" "User-facing legacy brand search" (
    "{0} occurrence(s) still need inspection." -f $oldBrandHits.Count
  )
  foreach ($hit in $oldBrandHits) {
    Add-Line $lines ("    - {0}" -f $hit)
  }
}

if ($technicalBrandHits.Count -gt 0) {
  Add-Check $lines "PASS" "Allowed technical legacy identifiers" (
    "{0} internal occurrence(s) intentionally retained." -f $technicalBrandHits.Count
  )
  foreach ($hit in $technicalBrandHits) {
    Add-Line $lines ("    - {0}" -f $hit)
  }
}

if ($placeholderHits.Count -eq 0) {
  Add-Check $lines "PASS" "Flutter web placeholders" "No default web placeholder metadata found."
} else {
  Add-Check $lines "FAIL" "Flutter web placeholders" (
    "{0} default placeholder occurrence(s) found." -f $placeholderHits.Count
  )
  foreach ($hit in $placeholderHits) {
    Add-Line $lines ("    - {0}" -f $hit)
  }
}

# -------------------------------------------------------------------
# 3. Localization parity
# -------------------------------------------------------------------
Add-Line $lines ""
Add-Line $lines "============================================================"
Add-Line $lines "3. LOCALIZATION PARITY"
Add-Line $lines "============================================================"

$locBasePath = Join-Path $projectRoot "lib/core/localization/app_localizations.dart"
$locViPath = Join-Path $projectRoot "lib/core/localization/app_localizations_vi.dart"
$locEnPath = Join-Path $projectRoot "lib/core/localization/app_localizations_en.dart"

if (
  (Test-Path $locBasePath) -and
  (Test-Path $locViPath) -and
  (Test-Path $locEnPath)
) {
  $base = Read-Utf8 $locBasePath
  $vi = Read-Utf8 $locViPath
  $en = Read-Utf8 $locEnPath

  $baseNames = New-Object 'System.Collections.Generic.HashSet[string]'
  [regex]::Matches($base, 'String\s+get\s+([A-Za-z0-9_]+)\s*;') |
    ForEach-Object { [void]$baseNames.Add($_.Groups[1].Value) }
  [regex]::Matches($base, 'String\s+([A-Za-z0-9_]+)\s*\([^;{]*\)\s*;') |
    ForEach-Object { [void]$baseNames.Add($_.Groups[1].Value) }

  function Get-OverrideNames([string]$text) {
    $set = New-Object 'System.Collections.Generic.HashSet[string]'
    [regex]::Matches(
      $text,
      '@override\s+String\s+get\s+([A-Za-z0-9_]+)'
    ) | ForEach-Object { [void]$set.Add($_.Groups[1].Value) }

    [regex]::Matches(
      $text,
      '@override\s+String\s+([A-Za-z0-9_]+)\s*\('
    ) | ForEach-Object { [void]$set.Add($_.Groups[1].Value) }

    return $set
  }

  $viNames = Get-OverrideNames $vi
  $enNames = Get-OverrideNames $en

  $missingVi = @($baseNames | Where-Object { -not $viNames.Contains($_) } | Sort-Object)
  $missingEn = @($baseNames | Where-Object { -not $enNames.Contains($_) } | Sort-Object)

  if ($missingVi.Count -eq 0 -and $missingEn.Count -eq 0) {
    Add-Check $lines "PASS" "VI/EN parity" (
      "{0} localization member(s) implemented in both languages." -f $baseNames.Count
    )
  } else {
    Add-Check $lines "FAIL" "VI/EN parity" "Missing localization implementations."
    if ($missingVi.Count -gt 0) {
      Add-Line $lines ("    Missing VI: {0}" -f ($missingVi -join ", "))
    }
    if ($missingEn.Count -gt 0) {
      Add-Line $lines ("    Missing EN: {0}" -f ($missingEn -join ", "))
    }
  }

  if ($vi -match "appName\s*=>\s*'Website hướng dẫn khởi nghiệp cùng Mầm'") {
    Add-Check $lines "PASS" "Vietnamese app name" "Current official website brand detected."
  } else {
    Add-Check $lines "REVIEW" "Vietnamese app name" "Expected official website brand not detected."
  }

  if ($en -match "appName\s*=>\s*'Entrepreneurship Guide with Mầm'") {
    Add-Check $lines "PASS" "English app name" "English display name detected."
  } else {
    Add-Check $lines "REVIEW" "English app name" "Expected English display name not detected."
  }
} else {
  Add-Check $lines "FAIL" "Localization files" "One or more localization source files are missing."
}

# -------------------------------------------------------------------
# 4. AI markers
# -------------------------------------------------------------------
Add-Line $lines ""
Add-Line $lines "============================================================"
Add-Line $lines "4. MẦM AI RELEASE MARKERS"
Add-Line $lines "============================================================"

$aiBackend = Join-Path $projectRoot "functions/index.js"
$aiPage = Join-Path $projectRoot "lib/features/ai/presentation/ai_page.dart"
$aiService = Join-Path $projectRoot "lib/features/ai/data/ai_service.dart"
$aiContext = Join-Path $projectRoot "lib/features/ai/data/ai_launch_context.dart"

if (Test-Path $aiBackend) {
  $text = Read-Utf8 $aiBackend

  foreach ($check in @(
    @("Mầm persona", "You are Mầm"),
    @("Context Firestore resolution", "resolveWorkbookContext"),
    @("MAX_TOKENS handling", "finishReason"),
    @("Automatic truncation retry", "retrying with a shorter-answer instruction"),
    @("Output budget", "PRIMARY_MAX_OUTPUT_TOKENS = 1200")
  )) {
    if ($text.Contains($check[1])) {
      Add-Check $lines "PASS" $check[0] "Detected in functions/index.js."
    } else {
      Add-Check $lines "FAIL" $check[0] ("Missing marker: {0}" -f $check[1])
    }
  }

  if ($text -match 'You are PsyCapNote AI') {
    Add-Check $lines "FAIL" "Legacy AI persona" "Backend still contains the legacy persona."
  } else {
    Add-Check $lines "PASS" "Legacy AI persona" "No legacy AI persona marker."
  }
}

if (Test-Path $aiPage) {
  $text = Read-Utf8 $aiPage
  foreach ($pair in @(
    @("Thinking state", "Mầm đang suy nghĩ..."),
    @("Clear confirmation", "_confirmClearConversation"),
    @("Auto-scroll", "_scheduleScrollToBottom"),
    @("Contextual AI header", "Mầm đang đồng hành với hoạt động này")
  )) {
    if ($text.Contains($pair[1])) {
      Add-Check $lines "PASS" $pair[0] "Detected."
    } else {
      Add-Check $lines "FAIL" $pair[0] ("Missing marker: {0}" -f $pair[1])
    }
  }
}

if (Test-Path $aiService) {
  $text = Read-Utf8 $aiService
  if ($text.Contains("Call Mầm first") -and $text.Contains("batch.commit")) {
    Add-Check $lines "PASS" "Failed-send protection" "Provider reply occurs before paired message persistence."
  } else {
    Add-Check $lines "REVIEW" "Failed-send protection" "Expected Phase 9C persistence markers not detected."
  }
}

if (Test-Path $aiContext) {
  $text = Read-Utf8 $aiContext
  if ($text.Contains("conversationId")) {
    Add-Check $lines "PASS" "Context thread isolation" "AiLaunchContext conversationId detected."
  } else {
    Add-Check $lines "FAIL" "Context thread isolation" "conversationId not detected."
  }
}

# -------------------------------------------------------------------
# 5. Routing
# -------------------------------------------------------------------
Add-Line $lines ""
Add-Line $lines "============================================================"
Add-Line $lines "5. ROUTING + PUBLIC QR"
Add-Line $lines "============================================================"

$router = Join-Path $projectRoot "lib/core/routing/app_router.dart"
if (Test-Path $router) {
  $text = Read-Utf8 $router
  foreach ($pair in @(
    @("Exact initial route generation", "onGenerateInitialRoutes"),
    @("Public resource route", "AppRoutes.resource"),
    @("Access-code route", "AppRoutes.access"),
    @("Contextual AI scope", "AiLaunchScope")
  )) {
    if ($text.Contains($pair[1])) {
      Add-Check $lines "PASS" $pair[0] "Detected."
    } else {
      Add-Check $lines "FAIL" $pair[0] ("Missing marker: {0}" -f $pair[1])
    }
  }
} else {
  Add-Check $lines "FAIL" "Router" "app_router.dart missing."
}

# -------------------------------------------------------------------
# 6. Firestore
# -------------------------------------------------------------------
Add-Line $lines ""
Add-Line $lines "============================================================"
Add-Line $lines "6. FIRESTORE RULES MARKERS"
Add-Line $lines "============================================================"

$rulesPath = Join-Path $projectRoot "firestore.rules"
if (Test-Path $rulesPath) {
  $rules = Read-Utf8 $rulesPath

  foreach ($pair in @(
    @("AI conversations", "aiConversations"),
    @("Workbook progress", "workbookProgress"),
    @("Reflections", "reflections"),
    @("Goals", "goals"),
    @("Access codes", "accessCodes")
  )) {
    if ($rules.Contains($pair[1])) {
      Add-Check $lines "PASS" $pair[0] "Rule marker detected."
    } else {
      Add-Check $lines "REVIEW" $pair[0] ("No '{0}' marker found." -f $pair[1])
    }
  }
}

# -------------------------------------------------------------------
# 7. PWA
# -------------------------------------------------------------------
Add-Line $lines ""
Add-Line $lines "============================================================"
Add-Line $lines "7. PWA + WEB METADATA"
Add-Line $lines "============================================================"

$indexPath = Join-Path $projectRoot "web/index.html"
if (Test-Path $indexPath) {
  $index = Read-Utf8 $indexPath

  foreach ($pair in @(
    @("UTF-8 meta", 'charset="UTF-8"'),
    @("Official page title", "Website hướng dẫn khởi nghiệp cùng Mầm"),
    @("Theme color", 'name="theme-color"'),
    @("Web description", 'name="description"')
  )) {
    if ($index.Contains($pair[1])) {
      Add-Check $lines "PASS" $pair[0] "Detected."
    } else {
      Add-Check $lines "REVIEW" $pair[0] ("Missing marker: {0}" -f $pair[1])
    }
  }
}

$manifestPath = Join-Path $projectRoot "web/manifest.json"
if (Test-Path $manifestPath) {
  try {
    $manifest = (Read-Utf8 $manifestPath) | ConvertFrom-Json

    if ($manifest.name -eq "Website hướng dẫn khởi nghiệp cùng Mầm") {
      Add-Check $lines "PASS" "PWA name" $manifest.name
    } else {
      Add-Check $lines "FAIL" "PWA name" ("Current: {0}" -f $manifest.name)
    }

    if ($manifest.short_name -eq "Cùng Mầm") {
      Add-Check $lines "PASS" "PWA short name" $manifest.short_name
    } else {
      Add-Check $lines "REVIEW" "PWA short name" ("Current: {0}" -f $manifest.short_name)
    }

    if ($manifest.display -in @("standalone", "minimal-ui")) {
      Add-Check $lines "PASS" "PWA display mode" $manifest.display
    } else {
      Add-Check $lines "REVIEW" "PWA display mode" ("Current: {0}" -f $manifest.display)
    }
  } catch {
    Add-Check $lines "FAIL" "PWA manifest JSON" $_.Exception.Message
  }
} else {
  Add-Check $lines "FAIL" "PWA manifest" "web/manifest.json missing."
}

# -------------------------------------------------------------------
# 8. Assets
# -------------------------------------------------------------------
Add-Line $lines ""
Add-Line $lines "============================================================"
Add-Line $lines "8. ASSET AUDIT"
Add-Line $lines "============================================================"

$assetRoot = Join-Path $projectRoot "assets"
if (Test-Path $assetRoot) {
  $assets = @(Get-ChildItem -LiteralPath $assetRoot -Recurse -File)
  $totalBytes = ($assets | Measure-Object -Property Length -Sum).Sum
  if ($null -eq $totalBytes) { $totalBytes = 0 }

  Add-Check $lines "PASS" "Assets found" (
    "{0} file(s), {1:N2} MB total." -f $assets.Count, ($totalBytes / 1MB)
  )

  $largeAssets = @(
    $assets |
      Where-Object { $_.Length -gt 700KB } |
      Sort-Object Length -Descending
  )

  if ($largeAssets.Count -eq 0) {
    Add-Check $lines "PASS" "Large assets" "No asset larger than 700 KB."
  } else {
    Add-Check $lines "REVIEW" "Large assets" (
      "{0} asset(s) larger than 700 KB." -f $largeAssets.Count
    )
    foreach ($asset in $largeAssets) {
      Add-Line $lines (
        "    - {0} ({1:N0} KB)" -f
        (Relative-Path $projectRoot $asset.FullName),
        ($asset.Length / 1KB)
      )
    }
  }

  $mascotRoot = Join-Path $assetRoot "mascot"
  if (Test-Path $mascotRoot) {
    $mascots = @(Get-ChildItem -LiteralPath $mascotRoot -Recurse -File)
    $nonWebp = @($mascots | Where-Object { $_.Extension.ToLowerInvariant() -ne ".webp" })
    Add-Check $lines "PASS" "Mascot inventory" (
      "{0} mascot asset(s)." -f $mascots.Count
    )

    if ($nonWebp.Count -gt 0) {
      Add-Check $lines "REVIEW" "Mascot formats" (
        "{0} mascot file(s) are not WebP." -f $nonWebp.Count
      )
      foreach ($asset in $nonWebp) {
        Add-Line $lines ("    - {0}" -f (Relative-Path $projectRoot $asset.FullName))
      }
    } else {
      Add-Check $lines "PASS" "Mascot formats" "Runtime mascot assets are WebP."
    }
  }
} else {
  Add-Check $lines "FAIL" "Assets directory" "assets/ missing."
}

# -------------------------------------------------------------------
# 9. Development leftovers
# -------------------------------------------------------------------
Add-Line $lines ""
Add-Line $lines "============================================================"
Add-Line $lines "9. DEVELOPMENT LEFTOVERS"
Add-Line $lines "============================================================"

$devSearches = @(
  @("localhost", "localhost"),
  @("127.0.0.1", "127\.0\.0\.1"),
  @("TODO", "\bTODO\b"),
  @("FIXME", "\bFIXME\b")
)

foreach ($entry in $devSearches) {
  $label = $entry[0]
  $pattern = $entry[1]
  $hits = New-Object 'System.Collections.Generic.List[string]'

  foreach ($file in $scanFiles) {
    try {
      $content = Read-Utf8 $file.FullName
    } catch {
      continue
    }

    $relative = Relative-Path $projectRoot $file.FullName
    $rows = $content -split "`r?`n"

    for ($i = 0; $i -lt $rows.Length; $i++) {
      if ($rows[$i] -match $pattern) {
        $hits.Add(
          ("{0}:{1}: {2}" -f $relative, ($i + 1), $rows[$i].Trim())
        ) | Out-Null
      }
    }
  }

  if ($hits.Count -eq 0) {
    Add-Check $lines "PASS" ("Search: {0}" -f $label) "No occurrence."
  } else {
    Add-Check $lines "REVIEW" ("Search: {0}" -f $label) (
      "{0} occurrence(s)." -f $hits.Count
    )
    foreach ($hit in $hits | Select-Object -First 20) {
      Add-Line $lines ("    - {0}" -f $hit)
    }
    if ($hits.Count -gt 20) {
      Add-Line $lines "    - ...more omitted"
    }
  }
}

# -------------------------------------------------------------------
# 10. Release harness
# -------------------------------------------------------------------
Add-Line $lines ""
Add-Line $lines "============================================================"
Add-Line $lines "10. RELEASE HARNESS"
Add-Line $lines "============================================================"

foreach ($relative in @(
  "docs/AI_QUALITY_TEST_MATRIX.md",
  "docs/AI_QUALITY_TEST_RESULTS_TEMPLATE.md",
  "docs/RELEASE_CHECKLIST.md",
  "docs/DEMO_FLOW_5_MIN.md"
)) {
  $path = Join-Path $projectRoot $relative
  if (Test-Path $path) {
    Add-Check $lines "PASS" $relative "Present."
  } else {
    Add-Check $lines "REVIEW" $relative "Missing."
  }
}

# -------------------------------------------------------------------
# Summary — exact prefixes, NOT wildcard character classes.
# -------------------------------------------------------------------
Add-Line $lines ""
Add-Line $lines "============================================================"
Add-Line $lines "SUMMARY"
Add-Line $lines "============================================================"

$passCount = @(
  $lines | Where-Object { $_.StartsWith("[PASS]") }
).Count
$reviewCount = @(
  $lines | Where-Object { $_.StartsWith("[REVIEW]") }
).Count
$failCount = @(
  $lines | Where-Object { $_.StartsWith("[FAIL]") }
).Count

Add-Line $lines ("PASS:   {0}" -f $passCount)
Add-Line $lines ("REVIEW: {0}" -f $reviewCount)
Add-Line $lines ("FAIL:   {0}" -f $failCount)
Add-Line $lines ""

if ($failCount -eq 0) {
  Add-Line $lines "No blocking audit failure was detected by this static checker."
  Add-Line $lines "REVIEW items are non-blocking but should be intentionally accepted or fixed before the final release."
} else {
  Add-Line $lines "Blocking audit findings exist. Fix FAIL items before production release."
}

[System.IO.File]::WriteAllLines($reportPath, $lines, $utf8)

Write-Host ""
Write-Host "Release audit complete." -ForegroundColor Green
Write-Host "Report:"
Write-Host "  $reportPath"
Write-Host ""
Write-Host ("PASS={0} REVIEW={1} FAIL={2}" -f $passCount, $reviewCount, $failCount)

if ($failCount -gt 0) {
  exit 2
}
