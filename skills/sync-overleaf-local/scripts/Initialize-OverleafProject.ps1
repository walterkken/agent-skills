param(
    [Parameter(Mandatory = $true)][string]$ProjectPath,
    [Parameter(Mandatory = $true)][string]$ProjectId,
    [Parameter(Mandatory = $true)][string]$ProjectName,
    [Parameter(Mandatory = $true)][string]$SourceZip,
    [string]$MainDocument = 'main.tex',
    [ValidateSet('pdflatex', 'xelatex', 'lualatex')][string]$Compiler = 'pdflatex'
)

. (Join-Path $PSScriptRoot 'Common.ps1')

$project = Resolve-OverleafProjectPath -ProjectPath $ProjectPath
$generatedPaths = @(
    '.overleaf-sync\config.json',
    '.overleaf-sync\baseline.json',
    '.gitattributes',
    '.gitignore',
    'AGENTS.md',
    '.vscode\settings.json',
    '.vscode\tasks.json',
    'build.ps1',
    'build.cmd'
)
$conflicts = @($generatedPaths | Where-Object {
    Test-Path -LiteralPath (Join-Path $project $_)
})
if ($conflicts.Count -gt 0) {
    throw "Initialization would overwrite existing project files; no files were written: $($conflicts -join ', ')"
}

$sourceZipFull = [System.IO.Path]::GetFullPath($SourceZip)
$backupPrefix = [System.IO.Path]::GetFullPath('E:\Overleaf\backups').TrimEnd('\') + '\'
if (-not $sourceZipFull.StartsWith($backupPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'The initial source ZIP must already be stored under E:\Overleaf\backups'
}
if (-not (Test-Path -LiteralPath $sourceZipFull -PathType Leaf)) {
    throw "Source ZIP not found: $sourceZipFull"
}
if (-not (Test-Path -LiteralPath (Join-Path $project $MainDocument) -PathType Leaf)) {
    throw "Main document not found: $MainDocument"
}

$syncDir = Join-Path $project '.overleaf-sync'
$vscodeDir = Join-Path $project '.vscode'
New-Item -ItemType Directory -Path $syncDir -Force | Out-Null
New-Item -ItemType Directory -Path $vscodeDir -Force | Out-Null

$localOnly = @(
    '.git',
    '.gitattributes',
    '.gitignore',
    '.overleaf-sync',
    '.vscode',
    'AGENTS.md',
    'build',
    'build.cmd',
    'build.ps1'
)

$config = [ordered]@{
    version = 1
    projectId = $ProjectId
    projectName = $ProjectName
    overleafUrl = "https://www.overleaf.com/project/$ProjectId"
    mainDocument = $MainDocument
    compiler = $Compiler
    localOnlyPaths = $localOnly
    lastBaselineAt = (Get-Date).ToString('o')
    lastBaselineZip = $sourceZipFull
    lastBaselineZipSha256 = (Get-FileHash -LiteralPath $sourceZipFull -Algorithm SHA256).Hash
}
$config | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $syncDir 'config.json') -Encoding utf8

@'
* text=auto eol=lf
*.bat text eol=crlf
*.cmd text eol=crlf
*.ps1 text eol=crlf
*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.pdf binary
'@ | Set-Content -LiteralPath (Join-Path $project '.gitattributes') -Encoding utf8

@'
/build/
*.aux
*.bbl
*.bcf
*.blg
*.fdb_latexmk
*.fls
*.log
*.out
*.run.xml
*.synctex.gz
*.toc
*.lof
*.lot
'@ | Set-Content -LiteralPath (Join-Path $project '.gitignore') -Encoding utf8

$agentText = @"
# Local Overleaf paper

- Project: $ProjectName
- Overleaf project ID: $ProjectId
- Main document: $MainDocument
- Compiler: $Compiler
- Store every manuscript file, Git object, build, export, backup, and synchronization artifact on drive E under E:\Overleaf.
- Before editing, compare a fresh Overleaf source ZIP when collaborators may have changed the online project.
- Build with .\build.cmd, review the Git diff, and commit coherent changes.
- Never upload .git, .overleaf-sync, .vscode, AGENTS.md, build outputs, or local helper files to Overleaf.
- Before publishing, prepare a clean staging directory and stop on any three-way conflict.
"@
$agentText | Set-Content -LiteralPath (Join-Path $project 'AGENTS.md') -Encoding utf8

@'
{
  "files.eol": "\n",
  "latex-workshop.latex.outDir": "%DIR%/build",
  "latex-workshop.latex.autoBuild.run": "onSave"
}
'@ | Set-Content -LiteralPath (Join-Path $vscodeDir 'settings.json') -Encoding utf8

@'
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "LaTeX: Build paper",
      "type": "shell",
      "command": "${workspaceFolder}\\build.cmd",
      "group": {
        "kind": "build",
        "isDefault": true
      },
      "problemMatcher": []
    }
  ]
}
'@ | Set-Content -LiteralPath (Join-Path $vscodeDir 'tasks.json') -Encoding utf8

@'
param()
& 'E:\Overleaf\skills\sync-overleaf-local\scripts\Build-OverleafProject.ps1' -ProjectPath $PSScriptRoot
exit $LASTEXITCODE
'@ | Set-Content -LiteralPath (Join-Path $project 'build.ps1') -Encoding utf8

@'
@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "E:\Overleaf\skills\sync-overleaf-local\scripts\Build-OverleafProject.ps1" -ProjectPath "%~dp0."
exit /b %errorlevel%
'@ | Set-Content -LiteralPath (Join-Path $project 'build.cmd') -Encoding ascii

$configObject = Get-OverleafConfig -ProjectPath $project
if (-not (Test-Path -LiteralPath (Join-Path $project '.git') -PathType Container)) {
    & git -C $project init -b main
    if ($LASTEXITCODE -ne 0) {
        throw 'git init failed'
    }
}
& git -C $project config core.autocrlf false
& git -C $project config core.eol lf
& git -C $project config core.longpaths true

& git -C $project add -A
if ($LASTEXITCODE -ne 0) {
    throw 'git add failed'
}

$publishable = Get-PublishableFiles -ProjectPath $project -Config $configObject
$baseline = [ordered]@{
    version = 1
    recordedAt = (Get-Date).ToString('o')
    sourceZip = $sourceZipFull
    sourceZipSha256 = (Get-FileHash -LiteralPath $sourceZipFull -Algorithm SHA256).Hash
    files = Get-FileManifest -Root $project -Files $publishable
}
$baseline | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $syncDir 'baseline.json') -Encoding utf8

& git -C $project add -A
& git -C $project commit -m "import(overleaf): $ProjectName baseline"
if ($LASTEXITCODE -ne 0) {
    throw 'Initial Git commit failed'
}

$tag = 'baseline-overleaf-' + (Get-Date -Format 'yyyyMMdd-HHmmss')
& git -C $project tag -a $tag -m "Overleaf baseline for $ProjectName"
if ($LASTEXITCODE -ne 0) {
    throw 'Initial Git tag failed'
}

[pscustomobject]@{
    Project = $project
    Branch = (& git -C $project branch --show-current)
    Commit = (& git -C $project rev-parse HEAD)
    Tag = $tag
    PublishableFiles = $publishable.Count
    BaselineZip = $sourceZipFull
}
