[CmdletBinding()]
param(
    [string]$RepoRoot,
    [switch]$SkipBuild
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
    $RepoRoot = (Resolve-Path (Join-Path $scriptRoot '..\..')).Path
}

$ownedSchemas = @('audit','config','core','coupons','discounts','events','gates','identity','integration','merchants','operations','operator_console','payments','reconciliation','sessions','sites')
foreach ($schema in $ownedSchemas) {
    $schemaPath = Join-Path $RepoRoot "objects\schemas\$schema"
    if (-not (Test-Path -LiteralPath $schemaPath)) { throw "Missing object source schema folder: objects/schemas/$schema" }
}
foreach ($excluded in @('public','pagila')) {
    if (Test-Path -LiteralPath (Join-Path $RepoRoot "objects\schemas\$excluded")) {
        throw "Excluded schema must not be represented as ExitPass-owned object source: $excluded"
    }
}

$applyOrder = Join-Path $RepoRoot 'objects\exitpass-full-object-apply-order.txt'
if (-not (Test-Path -LiteralPath $applyOrder)) { throw 'Missing objects/exitpass-full-object-apply-order.txt' }
$entries = Get-Content -LiteralPath $applyOrder | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') }
if ($entries.Count -eq 0) { throw 'Full apply-order has no object entries.' }
$duplicates = $entries | Group-Object | Where-Object Count -gt 1
if ($duplicates) { throw ('Duplicate full apply-order entries: ' + (($duplicates | ForEach-Object Name) -join ', ')) }
foreach ($entry in $entries) {
    $full = Join-Path $RepoRoot ($entry -replace '/', [IO.Path]::DirectorySeparatorChar)
    if (-not (Test-Path -LiteralPath $full)) { throw "Missing full apply-order object file: $entry" }
}

if (-not $SkipBuild) {
    & (Join-Path $RepoRoot 'scripts\build\Build-ExitPassFullObjectSql.ps1') -RepoRoot $RepoRoot
}
$generated = Join-Path $RepoRoot 'build\generated\exitpass-full-object.generated.sql'
if (-not (Test-Path -LiteralPath $generated)) { throw 'Full generated SQL was not produced.' }
$sql = Get-Content -LiteralPath $generated -Raw
foreach ($schema in $ownedSchemas) {
    if (-not ($sql.Contains("CREATE SCHEMA `"$schema`"") -or $sql.Contains("CREATE SCHEMA IF NOT EXISTS $schema") -or $sql.Contains("CREATE SCHEMA IF NOT EXISTS `"$schema`""))) {
        throw "Generated SQL does not contain schema declaration for $schema"
    }
}
$requiredMarkers = @(
    'core.parking_sessions',
    'core.tariff_snapshots',
    'core.payment_attempts',
    'core.payment_confirmations',
    'core.exit_authorizations',
    'payments.provider_sessions',
    'sessions.session_resolution_requests',
    'coupons.coupon_applications',
    'discounts.statutory_discount_validations',
    'gates.gate_authorization_consumptions',
    'operations.operator_action_logs',
    'reconciliation.reconciliation_runs',
    'sites.site_groups',
    'identity.users',
    'username_normalized',
    'identity.local_credentials',
    'identity.external_identity_providers',
    'identity.external_identity_bindings',
    'identity.user_mfa_authenticators',
    'identity.human_sessions',
    'identity.authentication_attempts',
    'identity.credential_challenges',
    'identity.user_role_scope_grants',
    'identity.privileged_access_requests',
    'identity.privileged_access_decisions',
    'human-authentication.session.self.view',
    'HUMAN_IDENTITY_EVENT_TYPE',
    'audit.audit_events',
    'integration.vendor_systems',
    'config.controlled_code_sets',
    'events.outbox_events',
    'operator_console.operator_shifts',
    'core.fiscal_issuance_references',
    'discounts.statutory_discount_payable_basis_applications',
    'discounts.apply_statutory_discount_payable_basis',
    'operator_console.operator_device_bindings'
)
foreach ($marker in $requiredMarkers) {
    $quoted = '"' + ($marker -replace '\.', '"."') + '"'
    if (-not ($sql.Contains($marker) -or $sql.Contains($quoted))) { throw "Generated SQL missing required marker: $marker" }
}

$categories = @('schema','types','tables','constraints','indexes','functions','triggers','views','comments')
$counts = [ordered]@{}
foreach ($category in $categories) {
    $counts[$category] = (Get-ChildItem -Path (Join-Path $RepoRoot 'objects\schemas') -Recurse -Directory -Filter $category | ForEach-Object { Get-ChildItem -Path $_.FullName -File -ErrorAction SilentlyContinue } | Measure-Object).Count
}
$counts['reference-data'] = (Get-ChildItem -Path (Join-Path $RepoRoot 'objects\reference-data') -File -ErrorAction SilentlyContinue | Measure-Object).Count
$counts['uat'] = (Get-ChildItem -Path (Join-Path $RepoRoot 'objects\uat') -File -ErrorAction SilentlyContinue | Measure-Object).Count
$counts['extensions'] = (Get-ChildItem -Path (Join-Path $RepoRoot 'objects\extensions') -File -ErrorAction SilentlyContinue | Measure-Object).Count
$total = (Get-ChildItem -Path (Join-Path $RepoRoot 'objects') -Recurse -File -Filter *.sql | Measure-Object).Count
Write-Host 'Full object source layout validation passed.'
Write-Host ('Object counts: ' + (($counts.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ', ') + ", total=$total")
