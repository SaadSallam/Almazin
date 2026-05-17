# =============================================================================
# Almazin App — Installer Build Script
# =============================================================================
# Usage: .\build-installer.ps1 -Version "1.0.0" -BuildDir "build/windows/x64/runner/Release"
#
# This script:
#   1. Copies the Flutter Windows build output to installer/Release
#   2. Copies the app icon
#   3. Runs Inno Setup compiler to generate setup.exe
# =============================================================================

param(
    [Parameter(Mandatory = $true)]
    [string]$InstallerVersion,

    [Parameter(Mandatory = $true)]
    [string]$ReleaseLabel,

    [Parameter(Mandatory = $false)]
    [string]$BuildDir = "build/windows/x64/runner/Release"
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path $PSScriptRoot -Parent
$installerDir = Join-Path $projectRoot "installer"
$releaseDir = Join-Path $projectRoot $BuildDir
$iconSource = Join-Path $projectRoot "windows/runner/resources/app_icon.ico"
$issScript = Join-Path $installerDir "almazin-setup.iss"
$outputDir = Join-Path $installerDir "output"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Almazin App — Installer Build" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host " Release Label: $ReleaseLabel" -ForegroundColor Yellow
Write-Host " Installer Version (numeric): $InstallerVersion" -ForegroundColor Yellow
Write-Host " Build dir:  $BuildDir" -ForegroundColor Yellow
Write-Host " Output:     $outputDir" -ForegroundColor Yellow
Write-Host ""

# ── Verify build output exists ───────────────────────────────────────────────
if (-not (Test-Path $releaseDir)) {
    Write-Error "Build output not found at: $releaseDir"
    Write-Error "Run 'flutter build windows --release' first."
    exit 1
}

Write-Host "[1/4] Verifying build output..." -ForegroundColor Green
$exePath = Join-Path $releaseDir "almazin_app.exe"
if (-not (Test-Path $exePath)) {
    Write-Error "Executable not found at: $exePath"
    exit 1
}
Write-Host "  ✓ Found: $exePath" -ForegroundColor Green

# ── Prepare installer directory ──────────────────────────────────────────────
Write-Host "[2/4] Preparing installer directory..." -ForegroundColor Green

# Clean previous Release folder in installer
$installerReleaseDir = Join-Path $installerDir "Release"
if (Test-Path $installerReleaseDir) {
    Remove-Item -Path $installerReleaseDir -Recurse -Force
}

# Copy build output to installer/Release
Copy-Item -Path $releaseDir -Destination $installerReleaseDir -Recurse -Force
Write-Host "  ✓ Copied build output to installer/Release" -ForegroundColor Green

# Copy icon
if (Test-Path $iconSource) {
    Copy-Item -Path $iconSource -Destination (Join-Path $installerDir "app_icon.ico") -Force
    Write-Host "  ✓ Copied app icon" -ForegroundColor Green
} else {
    Write-Warning "  Icon not found at: $iconSource (installer will use default icon)"
}

# ── Find Inno Setup compiler ─────────────────────────────────────────────────
Write-Host "[3/4] Locating Inno Setup compiler..." -ForegroundColor Green

$isccPaths = @(
    "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
    "C:\Program Files\Inno Setup 6\ISCC.exe",
    "C:\Program Files (x86)\Inno Setup 5\ISCC.exe",
    "C:\Program Files\Inno Setup 5\ISCC.exe"
)

$iscc = $null
foreach ($path in $isccPaths) {
    if (Test-Path $path) {
        $iscc = $path
        break
    }
}

if (-not $iscc) {
    # Try PATH
    $iscc = Get-Command "ISCC.exe" -ErrorAction SilentlyContinue
    if ($iscc) {
        $iscc = $iscc.Source
    }
}

if (-not $iscc) {
    Write-Error "Inno Setup compiler (ISCC.exe) not found."
    Write-Error "Install Inno Setup 6: https://jrsoftware.org/isdl.php"
    Write-Error "Or install via choco: choco install innosetup"
    exit 1
}

Write-Host "  ✓ Found: $iscc" -ForegroundColor Green

# ── Build installer ──────────────────────────────────────────────────────────
Write-Host "[4/4] Building installer..." -ForegroundColor Green

# Clean previous output
if (Test-Path $outputDir) {
    Remove-Item -Path $outputDir -Recurse -Force
}

# Run Inno Setup compiler
$arguments = @(
    "/DMyAppVersion=$ReleaseLabel",
    "/DMyAppVersionNumeric=$InstallerVersion",
    "`"$issScript`""
)

Write-Host "  Running: $iscc $arguments" -ForegroundColor Gray

$process = Start-Process -FilePath $iscc -ArgumentList $arguments -NoNewWindow -Wait -PassThru

if ($process.ExitCode -ne 0) {
    Write-Error "Inno Setup compilation failed with exit code $($process.ExitCode)"
    exit 1
}

# ── Verify output ────────────────────────────────────────────────────────────
$setupExe = Get-ChildItem -Path $outputDir -Filter "Almazin-Setup-*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $setupExe) {
    Write-Error "Installer output not found in: $outputDir"
    exit 1
}

$size = [math]::Round($setupExe.Length / 1MB, 2)

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Installer built successfully!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host " File: $($setupExe.Name)" -ForegroundColor Yellow
Write-Host " Size: $size MB" -ForegroundColor Yellow
Write-Host " Path: $($setupExe.FullName)" -ForegroundColor Yellow
Write-Host ""
