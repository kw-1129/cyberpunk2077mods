param([string]$GameDir = 'D:\steam\steamapps\common\Cyberpunk 2077')
$ErrorActionPreference = 'Stop'
if (Get-Process Cyberpunk2077 -ErrorAction SilentlyContinue) { throw 'Close Cyberpunk 2077 first.' }
$manifest = Get-Content (Join-Path $PSScriptRoot 'manifest.json') -Raw -Encoding UTF8 | ConvertFrom-Json
foreach ($file in $manifest.files) {
    if ($file.shared) { continue }
    $dest = Join-Path $GameDir $file.path
    if (Test-Path -LiteralPath $dest) {
        if ((Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash.ToLowerInvariant() -eq $file.sha256) {
            Remove-Item -LiteralPath $dest
        } else { Write-Host "Preserved modified file: $dest" }
    }
}
Write-Host 'Removed unmodified mod files. Shared frameworks and user settings were preserved.' -ForegroundColor Green
