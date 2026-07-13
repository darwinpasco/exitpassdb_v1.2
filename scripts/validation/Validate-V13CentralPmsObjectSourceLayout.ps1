[CmdletBinding()]
param(
    [string]$RepoRoot,
    [switch]$SkipBuild
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
    $RepoRoot = (Resolve-Path (Join-Path $scriptRoot '..\..')).Path
}$applyOrder = Join-Path $RepoRoot 'objects\v13-central-pms-object-apply-order.txt'
if (-not (Test-Path -LiteralPath $applyOrder)) {
    throw 'Missing objects/v13-central-pms-object-apply-order.txt'
}

$entries = Get-Content -LiteralPath $applyOrder |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and -not $_.StartsWith('#') }

if ($entries.Count -eq 0) {
    throw 'Apply-order file has no object entries.'
}

$duplicates = $entries | Group-Object | Where-Object Count -gt 1
if ($duplicates) {
    throw ('Duplicate apply-order entries: ' + (($duplicates | ForEach-Object Name) -join ', '))
}

foreach ($entry in $entries) {
    $full = Join-Path $RepoRoot ($entry -replace '/', [IO.Path]::DirectorySeparatorChar)
    if (-not (Test-Path -LiteralPath $full)) {
        throw "Missing apply-order object file: $entry"
    }
}

if (-not $SkipBuild) {
    & (Join-Path $RepoRoot 'scripts\build\Build-V13CentralPmsObjectSql.ps1') -RepoRoot $RepoRoot
}

$generated = Join-Path $RepoRoot 'build\generated\v13-central-pms-alignment.generated.sql'
if (-not (Test-Path -LiteralPath $generated)) {
    throw 'Generated SQL was not produced.'
}

$sql = Get-Content -LiteralPath $generated -Raw
$required = @(
    'core.fiscal_issuance_references',
    'operator_console.operator_shifts',
    'operator_console.operator_device_bindings',
    'discounts.statutory_discount_payable_basis_applications',
    'discounts.apply_statutory_discount_payable_basis',
    'management-platform.identity-rbac.inventory.read'
)

foreach ($needle in $required) {
    if (-not $sql.Contains($needle)) {
        throw "Generated SQL does not contain required object or seed marker: $needle"
    }
}

Write-Host "Object source layout validation passed for $($entries.Count) object files."


