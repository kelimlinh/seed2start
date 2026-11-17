param(
  [switch]$BuildWeb
)

$ErrorActionPreference = "Stop"
$projectRoot = (Get-Location).Path
$reportDir = Join-Path $projectRoot "release_reports"
New-Item -ItemType Directory -Force -Path $reportDir | Out-Null

$utf8 = New-Object System.Text.UTF8Encoding($false)
[Console]::OutputEncoding = $utf8
$OutputEncoding = $utf8

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logPath = Join-Path $reportDir "release_checks_$timestamp.txt"

function Run-Step([string]$name, [scriptblock]$command) {
  Write-Host ""
  Write-Host "== $name ==" -ForegroundColor Cyan

  [System.IO.File]::AppendAllText(
    $logPath,
    [Environment]::NewLine + "== $name ==" + [Environment]::NewLine,
    $utf8
  )

  $previousErrorActionPreference = $ErrorActionPreference

  try {
    $ErrorActionPreference = "Continue"

    if (Get-Variable -Name PSNativeCommandUseErrorActionPreference `
        -ErrorAction SilentlyContinue) {
      $previousNativePreference = $PSNativeCommandUseErrorActionPreference
      $PSNativeCommandUseErrorActionPreference = $false
    } else {
      $previousNativePreference = $null
    }

    $global:LASTEXITCODE = 0

    & $command 2>&1 | ForEach-Object {
      $line = $_.ToString()
      Write-Host $line
      [System.IO.File]::AppendAllText(
        $logPath,
        $line + [Environment]::NewLine,
        $utf8
      )
    }

    $exitCode = $LASTEXITCODE
  }
  finally {
    if ($null -ne $previousNativePreference) {
      $PSNativeCommandUseErrorActionPreference = $previousNativePreference
    }
    $ErrorActionPreference = $previousErrorActionPreference
  }

  if ($exitCode -ne 0) {
    throw "$name failed with exit code $exitCode. See $logPath"
  }

  Write-Host "PASS: $name" -ForegroundColor Green
}

if (-not (Test-Path (Join-Path $projectRoot "pubspec.yaml"))) {
  throw "Run this script from the Flutter project root."
}

Run-Step "flutter pub get" { flutter pub get }
Run-Step "flutter analyze" { flutter analyze }
Run-Step "flutter test" { flutter test }

if ($BuildWeb) {
  # The regular JS web build is the release target for this project.
  # --no-wasm-dry-run suppresses Flutter's informational Wasm suggestion;
  # it does NOT disable or remove normal Flutter Web functionality.
  Run-Step "flutter build web --release" {
    flutter build web --release --no-wasm-dry-run
  }

  $buildIndex = Join-Path $projectRoot "build/web/index.html"
  if (-not (Test-Path $buildIndex)) {
    throw "Release build reported success but build/web/index.html was not found."
  }

  Write-Host ""
  Write-Host "Release web artifact verified:" -ForegroundColor Green
  Write-Host "  $buildIndex"
}

Write-Host ""
Write-Host "Static Flutter checks passed." -ForegroundColor Green
Write-Host "Log:"
Write-Host "  $logPath"
