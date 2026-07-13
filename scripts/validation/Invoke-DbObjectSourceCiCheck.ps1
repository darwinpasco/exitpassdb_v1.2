[CmdletBinding()]
param(
    [string]$RepoRoot,
    [switch]$SkipDbApply,
    [switch]$RunDbApply,
    [string]$DbHost,
    [int]$DbPort = 5432,
    [string]$DbUser = 'exitpass',
    [string]$DbPassword,
    [string]$AdminDatabase = 'postgres',
    [string]$ValidationDatabase
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
    $RepoRoot = (Resolve-Path (Join-Path $scriptRoot '..\..')).Path
}
if ($SkipDbApply -and $RunDbApply) {
    throw 'Use either -SkipDbApply or -RunDbApply, not both.'
}

& (Join-Path $RepoRoot 'scripts\build\Build-ExitPassFullObjectSql.ps1') -RepoRoot $RepoRoot
& (Join-Path $RepoRoot 'scripts\build\Build-V13CentralPmsObjectSql.ps1') -RepoRoot $RepoRoot
& (Join-Path $RepoRoot 'scripts\validation\Validate-ExitPassFullObjectSourceLayout.ps1') -RepoRoot $RepoRoot -SkipBuild
& (Join-Path $RepoRoot 'scripts\validation\Validate-V13CentralPmsObjectSourceLayout.ps1') -RepoRoot $RepoRoot -SkipBuild

$coverageArgs = @{ RepoRoot = $RepoRoot }
if ($RunDbApply) {
    $coverageArgs.RunDbApply = $true
    if (-not [string]::IsNullOrWhiteSpace($DbHost)) { $coverageArgs.DbHost = $DbHost }
    if ($PSBoundParameters.ContainsKey('DbPort')) { $coverageArgs.DbPort = $DbPort }
    if (-not [string]::IsNullOrWhiteSpace($DbUser)) { $coverageArgs.DbUser = $DbUser }
    if (-not [string]::IsNullOrWhiteSpace($DbPassword)) { $coverageArgs.DbPassword = $DbPassword }
    if (-not [string]::IsNullOrWhiteSpace($AdminDatabase)) { $coverageArgs.AdminDatabase = $AdminDatabase }
    if (-not [string]::IsNullOrWhiteSpace($ValidationDatabase)) { $coverageArgs.ValidationDatabase = $ValidationDatabase }
} else {
    $coverageArgs.SkipDbApply = $true
}
& (Join-Path $RepoRoot 'scripts\validation\Invoke-DbObjectSourceCoverageReport.ps1') @coverageArgs

Write-Host 'DB object-source CI check passed.'
