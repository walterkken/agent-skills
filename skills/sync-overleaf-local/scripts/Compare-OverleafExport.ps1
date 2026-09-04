param(
    [Parameter(Mandatory = $true)][string]$ProjectPath,
    [Parameter(Mandatory = $true)][string]$SourceZip
)

. (Join-Path $PSScriptRoot 'Common.ps1')

$project = Resolve-OverleafProjectPath -ProjectPath $ProjectPath
$config = Get-OverleafConfig -ProjectPath $project
$baselinePath = Join-Path $project '.overleaf-sync\baseline.json'
if (-not (Test-Path -LiteralPath $baselinePath -PathType Leaf)) {
    throw "Missing baseline: $baselinePath"
}
$baseline = Get-Content -Raw -LiteralPath $baselinePath | ConvertFrom-Json

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$extract = Join-Path 'E:\Overleaf\temp' "$($config.projectName)\compare-$stamp"
$remoteRoot = Expand-OverleafSourceZip -ZipPath $SourceZip -Destination $extract

$localFiles = Get-PublishableFiles -ProjectPath $project -Config $config
$localManifest = Get-FileManifest -Root $project -Files $localFiles
$remoteFiles = @(Get-ChildItem -LiteralPath $remoteRoot -File -Recurse)
$remoteManifest = Get-FileManifest -Root $remoteRoot -Files $remoteFiles

$baselineMap = @{}
foreach ($item in $baseline.files) { $baselineMap[[string]$item.path] = [string]$item.sha256 }
$localMap = @{}
foreach ($item in $localManifest) { $localMap[[string]$item.path] = [string]$item.sha256 }
$remoteMap = @{}
foreach ($item in $remoteManifest) { $remoteMap[[string]$item.path] = [string]$item.sha256 }

$allPaths = @($baselineMap.Keys + $localMap.Keys + $remoteMap.Keys | Sort-Object -Unique)
$results = foreach ($path in $allPaths) {
    $baseHash = if ($baselineMap.ContainsKey($path)) { $baselineMap[$path] } else { $null }
    $localHash = if ($localMap.ContainsKey($path)) { $localMap[$path] } else { $null }
    $remoteHash = if ($remoteMap.ContainsKey($path)) { $remoteMap[$path] } else { $null }
    $localChanged = $localHash -ne $baseHash
    $remoteChanged = $remoteHash -ne $baseHash
    $statusName = if ($localChanged -and $remoteChanged) {
        if ($localHash -eq $remoteHash) { 'both-same' } else { 'conflict' }
    }
    elseif ($localChanged) { 'local-changed' }
    elseif ($remoteChanged) { 'remote-changed' }
    else { 'unchanged' }

    [pscustomobject]@{
        path = $path
        status = $statusName
        baselineSha256 = $baseHash
        localSha256 = $localHash
        remoteSha256 = $remoteHash
    }
}

$interesting = @($results | Where-Object status -ne 'unchanged')
$conflicts = @($results | Where-Object status -eq 'conflict')
$reportPath = Join-Path (Split-Path -Parent $extract) "comparison-$stamp.json"
$report = [ordered]@{
    version = 1
    createdAt = (Get-Date).ToString('o')
    project = $project
    sourceZip = [System.IO.Path]::GetFullPath($SourceZip)
    hasConflicts = $conflicts.Count -gt 0
    summary = [ordered]@{
        unchanged = @($results | Where-Object status -eq 'unchanged').Count
        localChanged = @($results | Where-Object status -eq 'local-changed').Count
        remoteChanged = @($results | Where-Object status -eq 'remote-changed').Count
        bothSame = @($results | Where-Object status -eq 'both-same').Count
        conflicts = $conflicts.Count
    }
    changes = $interesting
}
$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $reportPath -Encoding utf8

[pscustomobject]@{
    HasConflicts = $conflicts.Count -gt 0
    Conflicts = $conflicts.Count
    LocalChanges = @($results | Where-Object status -eq 'local-changed').Count
    RemoteChanges = @($results | Where-Object status -eq 'remote-changed').Count
    BothSame = @($results | Where-Object status -eq 'both-same').Count
    Report = $reportPath
    ExtractedRemote = $remoteRoot
}
