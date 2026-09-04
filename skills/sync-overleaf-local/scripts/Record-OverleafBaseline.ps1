param(
    [Parameter(Mandatory = $true)][string]$ProjectPath,
    [Parameter(Mandatory = $true)][string]$SourceZip
)

. (Join-Path $PSScriptRoot 'Common.ps1')

$project = Resolve-OverleafProjectPath -ProjectPath $ProjectPath
$config = Get-OverleafConfig -ProjectPath $project
$zipFull = [System.IO.Path]::GetFullPath($SourceZip)
if (-not (Test-Path -LiteralPath $zipFull -PathType Leaf)) {
    throw "Source ZIP not found: $zipFull"
}

$backupDir = [System.IO.Path]::GetFullPath((Join-Path 'E:\Overleaf\backups' "$($config.projectName)\downloads"))
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
$backupPrefix = $backupDir.TrimEnd('\') + '\'
if (-not $zipFull.StartsWith($backupPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $destination = Join-Path $backupDir "$($config.projectName)-overleaf-$stamp.zip"
    Move-Item -LiteralPath $zipFull -Destination $destination
    $zipFull = $destination
}

$stamp2 = Get-Date -Format 'yyyyMMdd-HHmmss'
$extract = Join-Path 'E:\Overleaf\temp' "$($config.projectName)\baseline-$stamp2"
$remoteRoot = Expand-OverleafSourceZip -ZipPath $zipFull -Destination $extract
$remoteFiles = @(Get-ChildItem -LiteralPath $remoteRoot -File -Recurse)
$manifest = Get-FileManifest -Root $remoteRoot -Files $remoteFiles

$baseline = [ordered]@{
    version = 1
    recordedAt = (Get-Date).ToString('o')
    sourceZip = $zipFull
    sourceZipSha256 = (Get-FileHash -LiteralPath $zipFull -Algorithm SHA256).Hash
    files = $manifest
}
$baselinePath = Join-Path $project '.overleaf-sync\baseline.json'
$baseline | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $baselinePath -Encoding utf8

$config.lastBaselineAt = $baseline.recordedAt
$config.lastBaselineZip = $zipFull
$config.lastBaselineZipSha256 = $baseline.sourceZipSha256
$config | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $project '.overleaf-sync\config.json') -Encoding utf8

[pscustomobject]@{
    Baseline = $baselinePath
    SourceZip = $zipFull
    SourceZipSha256 = $baseline.sourceZipSha256
    FileCount = $manifest.Count
}
