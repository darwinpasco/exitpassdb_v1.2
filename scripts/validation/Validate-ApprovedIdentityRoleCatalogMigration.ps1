[CmdletBinding()]
param([string]$RepoRoot)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
    $RepoRoot = (Resolve-Path (Join-Path $scriptRoot '..\..')).Path
}

$sourcePath = Join-Path $RepoRoot 'objects\reference-data\identity.v13-management-platform-role-permission-bundles.sql'
$migrationPath = Join-Path $RepoRoot 'migrations\20260917120000_v13_approved_identity_role_catalog.sql'
$directAddMigrationPath = Join-Path $RepoRoot 'migrations\20260918120000_v13_all_approved_roles_direct_add.sql'
$removeElevatedMigrationPath = Join-Path $RepoRoot 'migrations\20260919120000_v13_remove_elevated_role_workflow.sql'

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
    $matchingRow = @(Get-Content -LiteralPath $sourcePath | Where-Object { $_.StartsWith("('$roleCode',") -and $_.Contains("'CANONICAL_ROLE'") })
    if ($matchingRow.Count -ne 1 -or $matchingRow[0] -notmatch ',(true|false),false,true,true\),$') {
        throw "Canonical role $roleCode must be human-assignable, direct-add eligible, and free of elevated approval."
    }
}
if ($approvedCodes.Count -ne 8) { throw 'Exactly eight approved roles are required.' }
$directAddMigration = Read-NormalizedSql $directAddMigrationPath
$removeElevatedMigration = Read-NormalizedSql $removeElevatedMigrationPath
foreach ($roleCode in $approvedCodes) {
    if (-not $directAddMigration.Contains("'$roleCode'")) { throw "Direct Add User migration is missing $roleCode." }
    if (-not $removeElevatedMigration.Contains("'$roleCode'")) { throw "Elevated workflow removal migration is missing $roleCode." }
}
if ($source.Contains("SELECT 'SYSTEM_ADMIN',p.permission_code")) {
    throw 'Superseded SYSTEM_ADMIN all-permissions expansion remains in canonical source.'
}

Write-Host 'Approved Identity/RBAC clean-build and migration SQL are byte-equivalent after newline normalization.'
