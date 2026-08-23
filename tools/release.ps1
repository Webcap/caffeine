<#
.SYNOPSIS
    Automated Release Build Script for ReelRiot Mobile (Flutter).

.DESCRIPTION
    Executes pre-flight checks, automatic CalVer/build-number management, quality validation,
    compilation for selected flavors/targets, and outputs organized, checksummed release binaries.

.PARAMETER Flavor
    The build flavor to target ('prod' or 'dev'). Defaults to 'prod'.

.PARAMETER Target
    The build target ('Apk', 'SplitApk', 'AppBundle', 'All'). Defaults to 'Apk'.

.PARAMETER BumpVersion
    When specified, auto-increments the build number and updates CalVer date before building.

.PARAMETER UpdateChangelog
    When specified, generates a commit-based section in CHANGELOG.md.

.PARAMETER Clean
    When specified, runs 'flutter clean' before starting the build.

.PARAMETER SkipTests
    When specified, skips static analysis and test validation gates.

.PARAMETER PublishGithub
    When specified, creates a GitHub Release page using the GitHub CLI (gh).

.PARAMETER OutDir
    The destination directory for release artifacts. Defaults to 'build/outputs/releases'.

.EXAMPLE
    .\tools\release.ps1 -Flavor prod -Target Apk -BumpVersion
    .\tools\release.ps1 -Flavor dev -Target Apk
#>

[CmdletBinding()]
param (
    [ValidateSet('prod', 'dev')]
    [string]$Flavor = 'prod',

    [ValidateSet('Apk', 'SplitApk', 'AppBundle', 'All')]
    [string]$Target = 'Apk',

    [switch]$BumpVersion,
    [switch]$UpdateChangelog,
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
Write-Host " ChgLog : $UpdateChangelog" -ForegroundColor Yellow
Write-Host " OutDir : $OutDir" -ForegroundColor Yellow
Write-Host "======================================================"

# --- 1. Pre-flight Checks -----------------------------------------------------
Write-Host "`n[1/5] Checking prerequisites..." -ForegroundColor Cyan
if (-not (Get-Command "flutter" -ErrorAction SilentlyContinue)) {
    Write-Error "Flutter SDK was not found in PATH."
}
if (-not (Test-Path ".env")) {
    Write-Warning "No .env file found in workspace root. Using environment defaults."
}

# --- 2. Clean and Dependencies ------------------------------------------------
if ($Clean) {
    Write-Host "`n[2/5] Cleaning workspace..." -ForegroundColor Cyan
    & flutter clean
}

Write-Host "`n[2/5] Restoring dependencies..." -ForegroundColor Cyan
& flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Error "flutter pub get failed with exit code $LASTEXITCODE"
}

# --- 3. Version and Changelog Management --------------------------------------
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

if ($UpdateChangelog -or $BumpVersion) {
    Write-Host "-> Generating commit-based CHANGELOG.md entry..." -ForegroundColor Gray
    & dart tools/changelog_gen.dart --write
}

# --- 4. Quality Gate ----------------------------------------------------------
if (-not $SkipTests) {
    Write-Host "`n[4/5] Running Quality Gate (lints and SVG tests)..." -ForegroundColor Cyan
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

# --- 5. Compilation -----------------------------------------------------------
Write-Host "`n[5/5] Compiling release binaries..." -ForegroundColor Cyan

$EntryPoint = if ($Flavor -eq 'dev') { "lib/main_dev.dart" } else { "lib/main.dart" }
$SanitizedVersion = $AppVersion -replace '\+', '_'

# Ensure Output Directory exists
if (-not (Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
}

$Artifacts = @()

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

# Build AppBundle (AAB)
if ($Target -eq 'All' -or $Target -eq 'AppBundle') {
    Write-Host "-> Building App Bundle (.aab) for $Flavor..." -ForegroundColor Yellow
    try {
        & flutter build appbundle --flavor $Flavor -t $EntryPoint --release
        if ($LASTEXITCODE -eq 0) {
            $SrcAab = "build/app/outputs/bundle/${Flavor}Release/app-$Flavor-release.aab"
            if (Test-Path $SrcAab) {
                $DestAab = "$OutDir/ReelRiot-$Flavor-$SanitizedVersion.aab"
                Copy-Item -Path $SrcAab -Destination $DestAab -Force
                $Artifacts += $DestAab
            }
        } else {
            Write-Warning "AppBundle build failed. Note: Building .aab requires Android NDK tools for stripping native symbols locally."
        }
    } catch {
        Write-Warning "AppBundle build encountered an error: $_"
    }
}

# --- Summary and Checksums ----------------------------------------------------
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

# --- 6. Publish to GitHub Releases (Optional) ---------------------------------
if ($PublishGithub) {
    Write-Host "`nPublishing GitHub Release for v$AppVersion..." -ForegroundColor Cyan
    $GhCmd = Get-Command -Name "gh" -ErrorAction SilentlyContinue
    if ($null -ne $GhCmd) {
        $Tag = "v$AppVersion"
        $Title = "ReelRiot Mobile v$AppVersion"
        Write-Host "-> Creating release page with GitHub CLI..." -ForegroundColor Gray
        & gh release create $Tag $Artifacts --title $Title --generate-notes
        if ($LASTEXITCODE -eq 0) {
            $RepoName = (& gh repo view --json nameWithOwner -q .nameWithOwner)
            Write-Host "[OK] GitHub Release page published: https://github.com/$RepoName/releases/tag/$Tag" -ForegroundColor Green
        } else {
            Write-Warning "Failed to publish GitHub release using GitHub CLI."
        }
    } else {
        Write-Warning "GitHub CLI is not installed. To publish from local CLI, install gh (winget install GitHub.cli)."
    }
}
Write-Host ""
