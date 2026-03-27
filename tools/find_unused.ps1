
$assetsFile = "c:\Users\cnieves\Desktop\Projects\caffeine\all_assets.txt"
$libPath = "c:\Users\cnieves\Desktop\Projects\caffeine\lib"
$pubspecPath = "c:\Users\cnieves\Desktop\Projects\caffeine\pubspec.yaml"
$assets = Get-Content -Path $assetsFile
Write-Host "Total assets: $($assets.Count)"

$dartFiles = Get-ChildItem -Path $libPath -Filter *.dart -Recurse
$combinedCode = ""
foreach ($file in $dartFiles) {
    try {
        $combinedCode += [System.IO.File]::ReadAllText($file.FullName)
    } catch {}
}

# Add pubspec content too
$combinedCode += [System.IO.File]::ReadAllText($pubspecPath)
Write-Host "Combined code length (including pubspec): $($combinedCode.Length)"

$unused = @()
foreach ($assetPath in $assets) {
    $relPath = $assetPath.Replace("c:\Users\cnieves\Desktop\Projects\caffeine\", "")
    
    # Skip directories that we definitely want to keep
    if ($relPath -match "^assets\\profiles\\" -or $relPath -match "^assets\\images\\profiles\\" -or $relPath -match "^assets\\images\\country_flags\\" -or $relPath -match "^assets\\translations\\" -or $relPath -match "^assets\\ca\\" -or $relPath -match "\.json$" -or $relPath -match "logo\.png$" -or $relPath -match "app_icon\.jpg$") {
        continue
    }
    
    $fileName = [System.IO.Path]::GetFileName($assetPath)
    if ([string]::IsNullOrWhiteSpace($fileName)) { continue }
    
    # Escape fileName for IndexOf search (case sensitive by default in .NET IndexOf)
    # But usually assets in Flutter are small-case or exact match.
    if ($combinedCode.IndexOf($fileName) -lt 0) {
        $unused += $assetPath
    }
}

Write-Host "Unused assets: $($unused.Count)"
$unused | Out-File -FilePath "c:\Users\cnieves\Desktop\Projects\caffeine\unused_assets.txt" -Encoding utf8
