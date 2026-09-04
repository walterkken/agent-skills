Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:OverleafRoot = [System.IO.Path]::GetFullPath('E:\Overleaf')
$script:ProjectsRoot = [System.IO.Path]::GetFullPath('E:\Overleaf\projects')

function Resolve-OverleafProjectPath {
    param([Parameter(Mandatory = $true)][string]$ProjectPath)

    $full = [System.IO.Path]::GetFullPath($ProjectPath)
    $prefix = $script:ProjectsRoot.TrimEnd('\') + '\'
    if (-not $full.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Project must be inside $script:ProjectsRoot"
    }
    if (-not (Test-Path -LiteralPath $full -PathType Container)) {
        throw "Project directory does not exist: $full"
    }
    return $full
}

function Get-OverleafConfig {
    param([Parameter(Mandatory = $true)][string]$ProjectPath)

    $configPath = Join-Path $ProjectPath '.overleaf-sync\config.json'
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
        throw "Missing synchronization config: $configPath"
    }
    return Get-Content -Raw -LiteralPath $configPath | ConvertFrom-Json
}

function Test-LocalOnlyPath {
    param(
        [Parameter(Mandatory = $true)][string]$RelativePath,
        [Parameter(Mandatory = $true)]$Config
    )

    $normalized = $RelativePath.Replace('\', '/').TrimStart('/')
    foreach ($entry in $Config.localOnlyPaths) {
        $candidate = ([string]$entry).Replace('\', '/').Trim('/')
        if ($normalized.Equals($candidate, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
        if ($normalized.StartsWith($candidate + '/', [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }
    return $false
}

function Get-PublishableFiles {
    param(
        [Parameter(Mandatory = $true)][string]$ProjectPath,
        [Parameter(Mandatory = $true)]$Config
    )

    if (-not (Test-Path -LiteralPath (Join-Path $ProjectPath '.git') -PathType Container)) {
        throw "Not a Git repository: $ProjectPath"
    }

    $paths = & git -C $ProjectPath ls-files
    if ($LASTEXITCODE -ne 0) {
        throw 'git ls-files failed'
    }

    $files = foreach ($relative in $paths) {
        if ([string]::IsNullOrWhiteSpace($relative)) {
            continue
        }
        if (Test-LocalOnlyPath -RelativePath $relative -Config $Config) {
            continue
        }
        $full = Join-Path $ProjectPath $relative
        if (Test-Path -LiteralPath $full -PathType Leaf) {
            Get-Item -LiteralPath $full
        }
    }
    return @($files)
}

function Get-FileManifest {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][System.IO.FileInfo[]]$Files
    )

    $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd('\') + '\'
    $manifest = foreach ($file in $Files) {
        $full = [System.IO.Path]::GetFullPath($file.FullName)
        if (-not $full.StartsWith($rootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "File escaped manifest root: $full"
        }
        [pscustomobject]@{
            path = $full.Substring($rootFull.Length).Replace('\', '/')
            sha256 = (Get-FileHash -LiteralPath $full -Algorithm SHA256).Hash
            size = $file.Length
        }
    }
    return @($manifest | Sort-Object path)
}

function Expand-OverleafSourceZip {
    param(
        [Parameter(Mandatory = $true)][string]$ZipPath,
        [Parameter(Mandatory = $true)][string]$Destination
    )

    $zipFull = [System.IO.Path]::GetFullPath($ZipPath)
    $destFull = [System.IO.Path]::GetFullPath($Destination)
    $tempPrefix = [System.IO.Path]::GetFullPath('E:\Overleaf\temp').TrimEnd('\') + '\'
    if (-not $destFull.StartsWith($tempPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw 'Archive extraction destination must be inside E:\Overleaf\temp'
    }
    if (-not (Test-Path -LiteralPath $zipFull -PathType Leaf)) {
        throw "Source ZIP not found: $zipFull"
    }
    if (Test-Path -LiteralPath $destFull) {
        throw "Extraction destination already exists: $destFull"
    }

    New-Item -ItemType Directory -Path $destFull -Force | Out-Null
    Expand-Archive -LiteralPath $zipFull -DestinationPath $destFull

    $topFiles = @(Get-ChildItem -LiteralPath $destFull -File)
    $topDirs = @(Get-ChildItem -LiteralPath $destFull -Directory)
    if ($topFiles.Count -eq 0 -and $topDirs.Count -eq 1) {
        return $topDirs[0].FullName
    }
    return $destFull
}
