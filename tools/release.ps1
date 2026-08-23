<#
.SYNOPSIS
    Automated Release Build Script for ReelRiot Mobile (Flutter).

.DESCRIPTION
    Executes pre-flight checks, automatic CalVer/build-number management, quality validation,
    compilation for selected flavors/targets, and outputs organized, checksummed release binaries.

.PARAMETER Flavor
    The build flavor to target ('prod' or 'dev'). Defaults to 'prod'.

.PARAMETER Target
    The build target ('All', 'AppBundle', 'Apk', 'SplitApk'). Defaults to 'All'.

.PARAMETER BumpVersion
    When specified, auto-increments the build number and updates CalVer date before building.

.PARAMETER Clean
    When specified, runs 'flutter clean' before starting the build.

.PARAMETER SkipTests
    When specified, skips static analysis and test validation gates.

.PARAMETER OutDir
    The destination directory for release artifacts. Defaults to 'build/outputs/releases'.

.EXAMPLE
    .\tools\release.ps1 -Flavor prod -Target All -BumpVersion
    .\tools\release.ps1 -Flavor dev -Target Apk
#>

[CmdletBinding()]
param (
    [ValidateSet('prod', 'dev')]
    [string]$Flavor = 'prod',

    [ValidateSet('Apk', 'SplitApk', 'AppBundle', 'All')]
    [string]$Target = 'Apk',

    [switch]$BumpVersion,
    [switch]$Clean,
    [switch]$SkipTests,
    [switch]$PublishGithub,
    [string]$OutDir = 'build/outputs/releases'
)

$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path "$ScriptDir\.."

Set-Location $ProjectRoot

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "         ReelRiot Mobile Release Pipeline             " -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host " Flavor : $Flavor" -ForegroundColor Yellow
Write-Host " Target : $Target" -ForegroundColor Yellow
Write-Host " BumpVer: $BumpVersion" -ForegroundColor Yellow
Write-Host " OutDir : $OutDir" -ForegroundColor Yellow
Write-Host "======================================================"

# ── 1. Pre-flight Checks ──────────────────────────────────────────────────────
Write-Host "`n[1/5] Checking prerequisites..." -ForegroundColor Cyan
if (-not (Get-Command "flutter" -ErrorAction SilentlyContinue)) {
    Write-Error "Flutter SDK was not found in PATH."
}
if (-not (Test-Path ".env")) {
    Write-Warning "No .env file found in workspace root. Using environment defaults."
}

# ── 2. Clean & Dependencies ──────────────────────────────────────────────────
if ($Clean) {
    Write-Host "`n[2/5] Cleaning workspace..." -ForegroundColor Cyan
    & flutter clean
}

Write-Host "`n[2/5] Restoring dependencies..." -ForegroundColor Cyan
& flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Error "flutter pub get failed with exit code $LASTEXITCODE"
}

# ── 3. Version Management ─────────────────────────────────────────────────────
Write-Host "`n[3/5] Resolving build version..." -ForegroundColor Cyan
if ($BumpVersion) {
    & dart tools/build_number_gen.dart --mode auto
} else {
    & dart tools/build_number_gen.dart --sync
}

$PubspecContent = Get-Content "pubspec.yaml" -Raw
if ($PubspecContent -match 'version:\s*([^\r\n]+)') {
    $AppVersion = $matches[1].Trim()
} else {
    $AppVersion = "unknown"
}
Write-Host "-> Target Version: $AppVersion" -ForegroundColor Green

# ── 4. Quality Gate ───────────────────────────────────────────────────────────
if (-not $SkipTests) {
    Write-Host "`n[4/5] Running Quality Gate (lints & SVG tests)..." -ForegroundColor Cyan
    Write-Host "-> Running flutter analyze..." -ForegroundColor Gray
    & flutter analyze
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Static analysis failed. Fix issues before creating a release build."
    }

    Write-Host "-> Running SVG validation test..." -ForegroundColor Gray
    & flutter test test/svg_rigorous_validation_test.dart
    if ($LASTEXITCODE -ne 0) {
        Write-Error "SVG validation test failed."
    }
} else {
    Write-Host "`n[4/5] Quality Gate skipped (-SkipTests specified)." -ForegroundColor Yellow
}

# ── 5. Compilation ────────────────────────────────────────────────────────────
Write-Host "`n[5/5] Compiling release binaries..." -ForegroundColor Cyan

$EntryPoint = if ($Flavor -eq 'dev') { "lib/main_dev.dart" } else { "lib/main.dart" }
$SanitizedVersion = $AppVersion -replace '\+', '_'

# Ensure Output Directory exists
if (-not (Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
}

$Artifacts = @()

# Build AppBundle (AAB)
if ($Target -eq 'All' -or $Target -eq 'AppBundle') {
    Write-Host "-> Building App Bundle (.aab) for $Flavor..." -ForegroundColor Yellow
    & flutter build appbundle --flavor $Flavor -t $EntryPoint --release
    if ($LASTEXITCODE -ne 0) { Write-Error "AppBundle build failed." }

    $SrcAab = "build/app/outputs/bundle/${Flavor}Release/app-$Flavor-release.aab"
    if (Test-Path $SrcAab) {
        $DestAab = "$OutDir/ReelRiot-$Flavor-$SanitizedVersion.aab"
        Copy-Item -Path $SrcAab -Destination $DestAab -Force
        $Artifacts += $DestAab
    }
}

# Build Universal APK
if ($Target -eq 'All' -or $Target -eq 'Apk') {
    Write-Host "-> Building Universal APK for $Flavor..." -ForegroundColor Yellow
    & flutter build apk --flavor $Flavor -t $EntryPoint --release
    if ($LASTEXITCODE -ne 0) { Write-Error "Universal APK build failed." }

    $SrcApk = "build/app/outputs/flutter-apk/app-$Flavor-release.apk"
    if (Test-Path $SrcApk) {
        $DestApk = "$OutDir/ReelRiot-$Flavor-$SanitizedVersion-universal.apk"
        Copy-Item -Path $SrcApk -Destination $DestApk -Force
        $Artifacts += $DestApk
    }
}

# Build Split-per-ABI APKs
if ($Target -eq 'All' -or $Target -eq 'SplitApk') {
    Write-Host "-> Building Split-per-ABI APKs for $Flavor..." -ForegroundColor Yellow
    & flutter build apk --flavor $Flavor -t $EntryPoint --release --split-per-abi
    if ($LASTEXITCODE -ne 0) { Write-Error "Split APK build failed." }

    $Abis = @('arm64-v8a', 'armeabi-v7a', 'x86_64')
    foreach ($Abi in $Abis) {
        $SrcSplit = "build/app/outputs/flutter-apk/app-$Abi-$Flavor-release.apk"
        if (Test-Path $SrcSplit) {
            $DestSplit = "$OutDir/ReelRiot-$Flavor-$SanitizedVersion-$Abi.apk"
            Copy-Item -Path $SrcSplit -Destination $DestSplit -Force
            $Artifacts += $DestSplit
        }
    }
}

# ── Summary & Checksums ───────────────────────────────────────────────────────
Write-Host "`n======================================================" -ForegroundColor Green
Write-Host "              Release Build Succeeded!                " -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green
Write-Host " Version : $AppVersion" -ForegroundColor Yellow
Write-Host " Output  : $OutDir" -ForegroundColor Yellow
Write-Host " Artifacts Generated:" -ForegroundColor Cyan

foreach ($File in $Artifacts) {
    if (Test-Path $File) {
        $Item = Get-Item $File
        $SizeMb = [math]::Round($Item.Length / 1MB, 2)
        $Hash = (Get-FileHash -Path $File -Algorithm SHA256).Hash
        Write-Host "  * $($Item.Name) ($SizeMb MB)" -ForegroundColor White
        Write-Host "    SHA256: $Hash" -ForegroundColor DarkGray
    }
}
Write-Host "======================================================"

# ── 6. Publish to GitHub Releases (Optional) ──────────────────────────────────
if ($PublishGithub) {
    Write-Host "`nPublishing GitHub Release for v$AppVersion..." -ForegroundColor Cyan
    if (Get-Command "gh" -ErrorAction SilentlyContinue) {
        $Tag = "v$AppVersion"
        $Title = "ReelRiot Mobile v$AppVersion"
        $ReleaseFiles = $Artifacts -join ' '
        
        Write-Host "-> Creating release page with GitHub CLI (gh)..." -ForegroundColor Gray
        & gh release create $Tag $Artifacts --title $Title --generate-notes
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ GitHub Release page published successfully: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/releases/tag/$Tag" -ForegroundColor Green
        } else {
            Write-Warning "Failed to publish GitHub release using GitHub CLI."
        }
    } else {
        Write-Warning "GitHub CLI ('gh') is not installed. To publish automatically from local CLI, install gh (winget install GitHub.cli)."
    }
}
Write-Host ""
