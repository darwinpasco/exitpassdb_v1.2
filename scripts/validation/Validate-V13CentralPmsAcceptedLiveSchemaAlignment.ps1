[CmdletBinding()]
param([string]$RepoRoot)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

$sourcePath = Join-Path $RepoRoot 'objects\schemas\core\tables\core.v13-accepted-live-schema-alignment.sql'
$migrationPath = Join-Path $RepoRoot 'migrations\20261111150000_v13_central_pms_accepted_live_schema_alignment.sql'
$fullGeneratedPath = Join-Path $RepoRoot 'build\generated\exitpass-full-object.generated.sql'
$v13GeneratedPath = Join-Path $RepoRoot 'build\generated\v13-central-pms-alignment.generated.sql'

foreach ($path in @($sourcePath, $migrationPath, $fullGeneratedPath, $v13GeneratedPath)) {
    if (-not (Test-Path -LiteralPath $path)) { throw "Missing alignment artifact: $path" }
}

$source = Get-Content -LiteralPath $sourcePath -Raw
$migration = Get-Content -LiteralPath $migrationPath -Raw

if ($source -match '(?im)^\s*(INSERT|UPDATE|DELETE|MERGE)\s+') {
    throw 'Canonical structural alignment source must not contain data-changing DML.'
}

$requiredMarkers = @(
    'payments.payment_provider_routing_policies',
    'identity.devices',
    'identity.device_provisioning_credentials',
    'operator_console.operator_session_contexts',
    'core.parking_session_invoice_customer_information',
    'core.payment_attempt_invoice_customer_information',
    'core.terminal_cash_payment_commands',
    'core.terminal_cash_payment_command_audits',
    'discounts.statutory_beneficiary_identities',
    'discounts.statutory_discount_payable_basis_recalculations',
    'ist_configuration.real_site_catalog_members',
    'ist_configuration.site_operational_capabilities',
    'ist_configuration.statutory_coverage_register',
    'ist_configuration.resolve_real_site',
    'ist_configuration.real_site_operational_readiness',
    'trg_exit_authorizations_completion_ancestry',
    'trg_statutory_beneficiary_identity_final_immutable',
    'trg_sd_pbr__immutable'
)

foreach ($marker in $requiredMarkers) {
    $quoted = '"' + ($marker -replace '\.', '"."') + '"'
    if (-not ($source.Contains($marker) -or $source.Contains($quoted))) {
        throw "Canonical alignment source is missing required marker: $marker"
    }
}

$createdTables = [regex]::Matches($source, '(?im)^CREATE TABLE\s+').Count
if ($createdTables -ne 15) {
    throw "Expected 15 promoted tables, found $createdTables."
}

$migrationDml = [regex]::Matches($migration, '(?im)^\s*(INSERT|UPDATE|DELETE|MERGE)\s+')
if ($migrationDml.Count -ne 2 -or ($migrationDml | Where-Object Value -notmatch '(?i)^\s*UPDATE\s+').Count -ne 0) {
    throw 'Governed migration may contain only the two approved structural backfills.'
}

foreach ($table in @('integration.vendor_payment_acknowledgments', 'operator_console.operator_shifts')) {
    if (-not $migration.Contains("UPDATE $table")) {
        throw "Governed migration is missing the approved data-preserving backfill for $table."
    }
}

foreach ($generatedPath in @($fullGeneratedPath, $v13GeneratedPath)) {
    $generated = Get-Content -LiteralPath $generatedPath -Raw
    if (-not $generated.Contains('core.v13-accepted-live-schema-alignment.sql')) {
        throw "Generated artifact does not include the accepted live-schema alignment source: $generatedPath"
    }
}

Write-Host 'Accepted Central PMS live-schema alignment validation passed.'
Write-Host 'Promoted tables=15; configuration DML=0; governed structural backfills=2.'
