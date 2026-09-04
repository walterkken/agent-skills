param(
    [Parameter(Mandatory = $true)][string]$ProjectPath
)

. (Join-Path $PSScriptRoot 'Common.ps1')

$project = Resolve-OverleafProjectPath -ProjectPath $ProjectPath
$config = Get-OverleafConfig -ProjectPath $project
$main = Join-Path $project ([string]$config.mainDocument)
if (-not (Test-Path -LiteralPath $main -PathType Leaf)) {
    throw "Main document not found: $main"
}

$projectName = [string]$config.projectName
$buildDir = [System.IO.Path]::GetFullPath((Join-Path 'E:\Overleaf\temp' "$projectName\build"))
$exportDir = [System.IO.Path]::GetFullPath((Join-Path 'E:\Overleaf\exports' $projectName))
New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
New-Item -ItemType Directory -Path $exportDir -Force | Out-Null

$engineFlag = switch ([string]$config.compiler) {
    'xelatex' { '-xelatex' }
    'lualatex' { '-lualatex' }
    default { '-pdf' }
}

$mainName = Split-Path -Leaf $main
$mainBase = [System.IO.Path]::GetFileNameWithoutExtension($mainName)
$arguments = @(
    $engineFlag,
    '-interaction=nonstopmode',
    '-halt-on-error',
    '-file-line-error',
    "-outdir=$buildDir",
    $mainName
)

$previous = Get-Location
try {
    Set-Location -LiteralPath $project
    & latexmk @arguments
    if ($LASTEXITCODE -ne 0) {
        throw "latexmk failed with exit code $LASTEXITCODE"
    }
}
finally {
    Set-Location -LiteralPath $previous
}

$pdf = Join-Path $buildDir "$mainBase.pdf"
if (-not (Test-Path -LiteralPath $pdf -PathType Leaf)) {
    throw "Expected PDF was not produced: $pdf"
}
$export = Join-Path $exportDir "$projectName.pdf"
Copy-Item -LiteralPath $pdf -Destination $export -Force

[pscustomobject]@{
    Project = $project
    Compiler = [string]$config.compiler
    MainDocument = $mainName
    BuildDirectory = $buildDir
    ExportPdf = $export
    PdfBytes = (Get-Item -LiteralPath $export).Length
}
