param([string]$ProjectRoot = (Get-Location).Path)

$ErrorActionPreference = "Stop"
$utf8 = New-Object System.Text.UTF8Encoding($false)
[Console]::OutputEncoding = $utf8
$OutputEncoding = $utf8

$projectRoot = (Resolve-Path $ProjectRoot).Path
if (-not (Test-Path (Join-Path $projectRoot "pubspec.yaml"))) {
  throw "Run this script from the Flutter project root."
}

$reportDir = Join-Path $projectRoot "release_reports"
New-Item -ItemType Directory -Force -Path $reportDir | Out-Null
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportPath = Join-Path $reportDir "responsive_audit_$timestamp.txt"

$lines = New-Object 'System.Collections.Generic.List[string]'
function Add([string]$text = "") { $lines.Add($text) | Out-Null }
function Rel([string]$path) {
  $baseUri = New-Object System.Uri(($projectRoot.TrimEnd('\') + '\'))
  $pathUri = New-Object System.Uri($path)
  return [System.Uri]::UnescapeDataString(
    $baseUri.MakeRelativeUri($pathUri).ToString().Replace('/', '\')
  )
}

Add "WEBSITE HƯỚNG DẪN KHỞI NGHIỆP CÙNG MẦM"
Add "PHASE 10C — RESPONSIVE STATIC AUDIT"
Add ("Generated: {0}" -f (Get-Date))
Add ""

$dartFiles = @(Get-ChildItem -LiteralPath (Join-Path $projectRoot "lib") -Recurse -File -Filter "*.dart")

Add "============================================================"
Add "1. RESPONSIVE PRIMITIVES"
Add "============================================================"

$primitiveMap = @{
  "LayoutBuilder" = 0; "MediaQuery" = 0; "ConstrainedBox" = 0;
  "Flexible" = 0; "Expanded" = 0; "Wrap" = 0;
  "SingleChildScrollView" = 0; "ListView" = 0
}
foreach ($file in $dartFiles) {
  $text = [System.IO.File]::ReadAllText($file.FullName, $utf8)
  foreach ($key in @($primitiveMap.Keys)) {
    $primitiveMap[$key] += ([regex]::Matches($text, "\b$key\b")).Count
  }
}
foreach ($key in ($primitiveMap.Keys | Sort-Object)) {
  Add ("[INFO] {0}: {1}" -f $key, $primitiveMap[$key])
}

Add ""
Add "============================================================"
Add "2. LARGE FIXED-DIMENSION REVIEW"
Add "============================================================"
Add "These are not automatically bugs; inspect only on responsive screens."

$risky = New-Object 'System.Collections.Generic.List[string]'
foreach ($file in $dartFiles) {
  $text = [System.IO.File]::ReadAllText($file.FullName, $utf8)
  $rows = $text -split "`r?`n"
  for ($i = 0; $i -lt $rows.Length; $i++) {
    $row = $rows[$i]
    if (
      $row -notmatch 'maxWidth|maxHeight|minWidth|minHeight' -and
      (
        $row -match 'width\s*:\s*(?:const\s+)?([5-9][0-9]{2}|[1-9][0-9]{3,})(?:\.0)?\b' -or
        $row -match 'height\s*:\s*(?:const\s+)?([7-9][0-9]{2}|[1-9][0-9]{3,})(?:\.0)?\b'
      )
    ) {
      $risky.Add(("{0}:{1}: {2}" -f (Rel $file.FullName), ($i + 1), $row.Trim())) | Out-Null
    }
  }
}
if ($risky.Count -eq 0) {
  Add "[PASS] No obviously risky large fixed dimensions detected."
} else {
  Add ("[REVIEW] {0} occurrence(s)." -f $risky.Count)
  foreach ($hit in $risky | Select-Object -First 40) { Add ("    - {0}" -f $hit) }
}

Add ""
Add "============================================================"
Add "3. ROW HOTSPOTS"
Add "============================================================"
$rowCounts = @()
foreach ($file in $dartFiles) {
  $text = [System.IO.File]::ReadAllText($file.FullName, $utf8)
  $count = ([regex]::Matches($text, '\bRow\s*\(')).Count
  if ($count -ge 5) {
    $rowCounts += [pscustomobject]@{File = Rel $file.FullName; Count = $count}
  }
}
if ($rowCounts.Count -eq 0) {
  Add "[PASS] No file with 5+ Row widgets."
} else {
  foreach ($item in $rowCounts | Sort-Object Count -Descending | Select-Object -First 30) {
    Add ("[REVIEW] {0} — Row x{1}" -f $item.File, $item.Count)
  }
}

Add ""
Add "============================================================"
Add "4. TEXT HOTSPOTS"
Add "============================================================"
$hardMaxLines = New-Object 'System.Collections.Generic.List[string]'
foreach ($file in $dartFiles) {
  $text = [System.IO.File]::ReadAllText($file.FullName, $utf8)
  $rows = $text -split "`r?`n"
  for ($i = 0; $i -lt $rows.Length; $i++) {
    if ($rows[$i] -match 'maxLines\s*:\s*[12]\b') {
      $hardMaxLines.Add(("{0}:{1}: {2}" -f (Rel $file.FullName), ($i + 1), $rows[$i].Trim())) | Out-Null
    }
  }
}
Add ("[INFO] maxLines 1–2 occurrence(s): {0}" -f $hardMaxLines.Count)
foreach ($hit in $hardMaxLines | Select-Object -First 30) { Add ("    - {0}" -f $hit) }

Add ""
Add "============================================================"
Add "5. MASCOT RESPONSIVE MARKERS"
Add "============================================================"
$mamPath = Join-Path $projectRoot "lib/core/widgets/mam_illustration.dart"
if (Test-Path $mamPath) {
  $mam = [System.IO.File]::ReadAllText($mamPath, $utf8)
  if ($mam.Contains("BoxFit.contain")) { Add "[PASS] Mầm uses BoxFit.contain." }
  else { Add "[REVIEW] Mầm widget does not contain BoxFit.contain marker." }
  if ($mam.Contains("Semantics")) { Add "[PASS] Mầm semantics marker detected." }
  else { Add "[REVIEW] No Semantics marker detected in Mầm widget." }
} else {
  Add "[FAIL] mam_illustration.dart missing."
}

Add ""
Add "============================================================"
Add "6. REQUIRED MANUAL VIEWPORT MATRIX"
Add "============================================================"
Add "360 x 800"
Add "390 x 844"
Add "768 x 1024"
Add "1024 x 768"
Add "1366 x 768"
Add "1440 x 900"
Add ""
Add "Test both Vietnamese and English."
Add "Use docs/RESPONSIVE_TEST_MATRIX.md to record PASS/FAIL."

[System.IO.File]::WriteAllLines($reportPath, $lines, $utf8)
Write-Host ""
Write-Host "Responsive static audit complete." -ForegroundColor Green
Write-Host "Report:"
Write-Host "  $reportPath"
