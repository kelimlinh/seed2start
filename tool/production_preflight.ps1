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
$reportPath = Join-Path $reportDir "production_preflight_$timestamp.txt"

$lines = New-Object 'System.Collections.Generic.List[string]'
$fail = 0; $review = 0
function Add([string]$text = "") { $lines.Add($text) | Out-Null }
function Pass([string]$name,[string]$detail="") { Add ("[PASS] {0}" -f $name); if($detail){Add ("    {0}" -f $detail)}}
function Review([string]$name,[string]$detail="") { $script:review += 1; Add ("[REVIEW] {0}" -f $name); if($detail){Add ("    {0}" -f $detail)}}
function Fail([string]$name,[string]$detail="") { $script:fail += 1; Add ("[FAIL] {0}" -f $name); if($detail){Add ("    {0}" -f $detail)}}

Add "WEBSITE HƯỚNG DẪN KHỞI NGHIỆP CÙNG MẦM"
Add "PHASE 10C — PRODUCTION PREFLIGHT"
Add ("Generated: {0}" -f (Get-Date))
Add ""

$buildIndex = Join-Path $projectRoot "build/web/index.html"
if (Test-Path $buildIndex) { Pass "Release web build" "build/web/index.html exists." }
else { Fail "Release web build" "Run .\tool\run_release_checks.ps1 -BuildWeb first." }

$firebaseCmd = Get-Command firebase -ErrorAction SilentlyContinue
if ($null -eq $firebaseCmd) { Fail "Firebase CLI" "firebase command not found." }
else { Pass "Firebase CLI" $firebaseCmd.Source }

$firebasercPath = Join-Path $projectRoot ".firebaserc"
if (Test-Path $firebasercPath) {
  try {
    $firebaserc = [System.IO.File]::ReadAllText($firebasercPath,$utf8) | ConvertFrom-Json
    $defaultProject = $firebaserc.projects.default
    if ($defaultProject -eq "psycapweb") { Pass "Default Firebase project" "psycapweb" }
    elseif ($defaultProject) { Review "Default Firebase project" ("Current: {0}; historically expected psycapweb." -f $defaultProject) }
    else { Review "Default Firebase project" "No default project configured." }
  } catch { Fail ".firebaserc JSON" $_.Exception.Message }
} else {
  Review ".firebaserc" "Missing. Confirm with `firebase use` before deploy."
}

$firebaseJsonPath = Join-Path $projectRoot "firebase.json"
if (Test-Path $firebaseJsonPath) {
  try {
    $config = [System.IO.File]::ReadAllText($firebaseJsonPath,$utf8) | ConvertFrom-Json
    $hostingConfigs = @()
    if ($config.hosting -is [System.Array]) { $hostingConfigs = @($config.hosting) }
    elseif ($null -ne $config.hosting) { $hostingConfigs = @($config.hosting) }

    if ($hostingConfigs.Count -eq 0) {
      Fail "Firebase Hosting config" "No hosting block."
    } else {
      $hosting = $hostingConfigs[0]
      if ($hosting.public -eq "build/web") { Pass "Hosting public directory" "build/web" }
      else { Review "Hosting public directory" ("Current: {0}" -f $hosting.public) }

      $hasSpaRewrite = $false
      foreach ($rewrite in @($hosting.rewrites)) {
        if ($rewrite.source -eq "**" -and $rewrite.destination -eq "/index.html") { $hasSpaRewrite = $true }
      }
      if ($hasSpaRewrite) { Pass "SPA rewrite" "** -> /index.html" }
      else { Review "SPA rewrite" "Not found. Hash routes still work; rewrite is recommended for future path URL strategy." }
    }
  } catch { Fail "firebase.json JSON" $_.Exception.Message }
} else { Fail "firebase.json" "Missing." }

if (Test-Path (Join-Path $projectRoot "firestore.rules")) { Pass "Firestore rules source" "Present." }
else { Fail "Firestore rules source" "Missing." }

$functionsIndex = Join-Path $projectRoot "functions/index.js"
if (Test-Path $functionsIndex) {
  $text = [System.IO.File]::ReadAllText($functionsIndex,$utf8)
  if ($text.Contains("exports.aiCoach")) { Pass "aiCoach source" "Callable function detected." }
  else { Fail "aiCoach source" "exports.aiCoach marker not found." }
} else { Fail "Functions backend" "functions/index.js missing." }

$routerPath = Join-Path $projectRoot "lib/core/routing/app_router.dart"
if (Test-Path $routerPath) {
  $router = [System.IO.File]::ReadAllText($routerPath,$utf8)
  if ($router.Contains("onGenerateInitialRoutes") -and $router.Contains("AppRoutes.resource") -and $router.Contains("AppRoutes.access")) {
    Pass "Public deep-link routing" "Initial/resource/access markers detected."
  } else { Fail "Public deep-link routing" "One or more markers missing." }
}

Review "Production QR domain" "After Hosting deploy, verify final /#/r/... and /#/access/... URLs on a real phone."

Add ""
Add "============================================================"
Add "SUMMARY"
Add "============================================================"
Add ("FAIL: {0}" -f $fail)
Add ("REVIEW: {0}" -f $review)
if ($fail -eq 0) {
  Add "No blocking static failure. Complete responsive + E2E manual checks before deploy."
} else {
  Add "Fix blocking failures before deployment."
}

[System.IO.File]::WriteAllLines($reportPath,$lines,$utf8)
Write-Host ""
Write-Host "Production preflight complete." -ForegroundColor Green
Write-Host "Report:"
Write-Host "  $reportPath"
Write-Host ("FAIL={0} REVIEW={1}" -f $fail,$review)
if ($fail -gt 0) { exit 2 }
