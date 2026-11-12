param([string]$GameDir = 'D:\steam\steamapps\common\Cyberpunk 2077')
$ErrorActionPreference = 'Stop'
$source = Join-Path $PSScriptRoot 'GameRoot'
$manifestPath = Join-Path $PSScriptRoot 'manifest.json'
if (!(Test-Path (Join-Path $GameDir 'bin\x64\Cyberpunk2077.exe'))) { throw 'Game root not found. Pass -GameDir with the correct directory.' }
if (Get-Process Cyberpunk2077 -ErrorAction SilentlyContinue) { throw 'Close Cyberpunk 2077 before installing.' }
$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$conflicts = @()
foreach ($file in $manifest.files) {
    $src = Join-Path $source $file.path
    if ((Get-FileHash -LiteralPath $src -Algorithm SHA256).Hash.ToLowerInvariant() -ne $file.sha256) { throw "Package hash mismatch: $($file.path)" }
    $dest = Join-Path $GameDir $file.path
    if ((Test-Path -LiteralPath $dest) -and !$file.preserveExisting -and (Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash.ToLowerInvariant() -ne $file.sha256) { $conflicts += $file.path }
}
if ($conflicts.Count -gt 0) { throw ("Existing different files; no files were changed:`n" + ($conflicts -join "`n")) }
$receiptPath = Join-Path $PSScriptRoot 'installed-files.json'
$created = @()
if (Test-Path $receiptPath) { $created = @(Get-Content $receiptPath -Raw -Encoding UTF8 | ConvertFrom-Json) }
foreach ($file in $manifest.files) {
    $dest = Join-Path $GameDir $file.path
    if (!(Test-Path -LiteralPath $dest)) {
        New-Item -ItemType Directory -Path (Split-Path $dest) -Force | Out-Null
        Copy-Item -LiteralPath (Join-Path $source $file.path) -Destination $dest
        $created += [PSCustomObject]@{path=$dest;sha256=$file.sha256;shared=$file.shared}
    }
}
ConvertTo-Json -InputObject @($created) -Depth 4 | Set-Content -LiteralPath $receiptPath -Encoding UTF8
Write-Host "Installed $($manifest.name). Existing identical dependencies were reused." -ForegroundColor Green
Write-Host 'First launch: bind the CET overlay key, then open CET Bindings for mod hotkeys.'
