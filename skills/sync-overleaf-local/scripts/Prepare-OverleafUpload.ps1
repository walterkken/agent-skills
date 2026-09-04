param(
    [Parameter(Mandatory = $true)][string]$ProjectPath
)

. (Join-Path $PSScriptRoot 'Common.ps1')

$project = Resolve-OverleafProjectPath -ProjectPath $ProjectPath
$config = Get-OverleafConfig -ProjectPath $project
$status = @(& git -C $project status --porcelain)
if ($LASTEXITCODE -ne 0) {
    throw 'git status failed'
}
if ($status.Count -gt 0) {
    throw 'Commit or discard local changes before preparing an Overleaf upload.'
}

$files = Get-PublishableFiles -ProjectPath $project -Config $config
if ($files.Count -eq 0) {
    throw 'No publishable files were found.'
}

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$projectName = [string]$config.projectName
$stage = [System.IO.Path]::GetFullPath((Join-Path 'E:\Overleaf\temp' "$projectName\upload-$stamp"))
New-Item -ItemType Directory -Path $stage -Force | Out-Null

$projectPrefix = $project.TrimEnd('\') + '\'
$suspicious = @()
foreach ($file in $files) {
    $relative = $file.FullName.Substring($projectPrefix.Length).Replace('\', '/')
    if ($relative -match '(^|/)(\.env($|\.)|id_rsa$|id_ed25519$|[^/]*\.pem$|[^/]*\.key$|credentials[^/]*\.json$)') {
        $suspicious += $relative
        continue
    }
    if ($file.Length -le 5MB) {
        $head = Get-Content -Raw -LiteralPath $file.FullName -ErrorAction SilentlyContinue
        if ($head -match '-----BEGIN [A-Z ]*PRIVATE KEY-----') {
            $suspicious += $relative
            continue
        }
    }
    $destination = Join-Path $stage $relative
    $destinationDir = Split-Path -Parent $destination
    New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
    Copy-Item -LiteralPath $file.FullName -Destination $destination
}

if ($suspicious.Count -gt 0) {
    throw ('Potential secret-bearing files were blocked: ' + ($suspicious -join ', '))
}

$manifestPath = "$stage.manifest.json"
$manifest = [ordered]@{
    version = 1
    createdAt = (Get-Date).ToString('o')
    project = $project
    gitCommit = (& git -C $project rev-parse HEAD)
    stagingDirectory = $stage
    files = Get-FileManifest -Root $stage -Files @(Get-ChildItem -LiteralPath $stage -File -Recurse)
}
$manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $manifestPath -Encoding utf8

[pscustomobject]@{
    StagingDirectory = $stage
    Manifest = $manifestPath
    FileCount = $files.Count
    TotalBytes = ($files | Measure-Object Length -Sum).Sum
}
