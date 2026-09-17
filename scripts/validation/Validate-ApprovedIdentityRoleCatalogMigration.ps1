[CmdletBinding()]
param([string]$RepoRoot)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
    $RepoRoot = (Resolve-Path (Join-Path $scriptRoot '..\..')).Path
}

$sourcePath = Join-Path $RepoRoot 'objects\reference-data\identity.v13-management-platform-role-permission-bundles.sql'
$migrationPath = Join-Path $RepoRoot 'migrations\20260917120000_v13_approved_identity_role_catalog.sql'

function Read-NormalizedSql([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { throw "Required SQL file not found: $Path" }
    return ((Get-Content -LiteralPath $Path -Raw) -replace "`r`n", "`n" -replace "`r", "`n").TrimEnd()
}

$source = Read-NormalizedSql $sourcePath
$migration = Read-NormalizedSql $migrationPath
if ($source -cne $migration) {
    throw 'The approved Identity/RBAC migration has drifted from the canonical clean-build reference data.'
}

$approvedCodes = @(
    'SYSTEM_ADMINISTRATOR','OPERATIONS_SUPERVISOR','SITE_OPERATOR','PARKING_ATTENDANT',
    'APT_CASHIER_OPERATOR','FINANCE_RECONCILIATION_ANALYST',
    'COMPLIANCE_POLICY_ADMINISTRATOR','EXECUTIVE_MANAGEMENT'
)
foreach ($roleCode in $approvedCodes) {
    if (-not $source.Contains("('$roleCode'")) { throw "Canonical role source is missing $roleCode." }
}
if ($source.Contains("SELECT 'SYSTEM_ADMIN',p.permission_code")) {
    throw 'Superseded SYSTEM_ADMIN all-permissions expansion remains in canonical source.'
}

Write-Host 'Approved Identity/RBAC clean-build and migration SQL are byte-equivalent after newline normalization.'
