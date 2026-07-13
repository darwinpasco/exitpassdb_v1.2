[CmdletBinding()]
param(
    [string]$RepoRoot,
    [string]$OutputDirectory = 'build\reports',
    [switch]$SkipDbApply,
    [switch]$RunDbApply,
    [string]$DockerContainer = 'exitpass-postgres',
    [string]$DbHost,
    [int]$DbPort = 5432,
    [string]$DbUser = 'exitpass',
    [string]$DbPassword,
    [string]$AdminDatabase = 'postgres',
    [string]$ValidationDatabase,
    [string]$DbName = 'exitpass_object_source_coverage_validation'
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
    $RepoRoot = (Resolve-Path (Join-Path $scriptRoot '..\..')).Path
}
if ($SkipDbApply -and $RunDbApply) {
    throw 'Use either -SkipDbApply or -RunDbApply, not both.'
}
if ([string]::IsNullOrWhiteSpace($ValidationDatabase)) { $ValidationDatabase = $DbName }
if ([string]::IsNullOrWhiteSpace($DbHost) -and -not [string]::IsNullOrWhiteSpace($env:EXITPASS_DB_HOST)) { $DbHost = $env:EXITPASS_DB_HOST }
if ($DbPort -eq 5432 -and -not [string]::IsNullOrWhiteSpace($env:EXITPASS_DB_PORT)) { $DbPort = [int]$env:EXITPASS_DB_PORT }
if ([string]::IsNullOrWhiteSpace($DbUser) -and -not [string]::IsNullOrWhiteSpace($env:EXITPASS_DB_USER)) { $DbUser = $env:EXITPASS_DB_USER }
if ([string]::IsNullOrWhiteSpace($DbPassword) -and -not [string]::IsNullOrWhiteSpace($env:EXITPASS_DB_PASSWORD)) { $DbPassword = $env:EXITPASS_DB_PASSWORD }
if ([string]::IsNullOrWhiteSpace($AdminDatabase) -and -not [string]::IsNullOrWhiteSpace($env:EXITPASS_DB_ADMIN_DATABASE)) { $AdminDatabase = $env:EXITPASS_DB_ADMIN_DATABASE }
if ($ValidationDatabase -eq $DbName -and -not [string]::IsNullOrWhiteSpace($env:EXITPASS_DB_VALIDATION_DATABASE)) { $ValidationDatabase = $env:EXITPASS_DB_VALIDATION_DATABASE }

function ConvertTo-RepoPath {
    param([string]$FullPath)
    return $FullPath.Substring($RepoRoot.Length + 1).Replace('\', '/')
}

function Get-ApplyOrderEntries {
    param([string]$Path)
    return @(Get-Content -LiteralPath $Path | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') })
}

function Test-GeneratedMarker {
    param([string]$Sql, [string]$Marker)
    $quoted = '"' + ($Marker -replace '\.', '"."') + '"'
    return ($Sql.Contains($Marker) -or $Sql.Contains($quoted))
}

$failures = New-Object System.Collections.Generic.List[string]
function Add-Failure {
    param([string]$Message)
    [void]$failures.Add($Message)
}

$ownedSchemas = @('audit','config','core','coupons','discounts','events','gates','identity','integration','merchants','operations','operator_console','payments','reconciliation','sessions','sites')
$excludedSchemas = @('public','pagila')
$objectsRoot = Join-Path $RepoRoot 'objects'
$outputRoot = Join-Path $RepoRoot $OutputDirectory
New-Item -ItemType Directory -Force -Path $outputRoot | Out-Null

$branch = 'unknown'
try {
    $branch = (& git -C $RepoRoot branch --show-current).Trim()
} catch {
    $branch = 'unknown'
}

$schemaCoverage = [ordered]@{
    ownedSchemas = @()
    missingOwnedSchemas = @()
    excludedSchemaFoldersPresent = @()
    extensionObjects = @()
}
foreach ($schema in $ownedSchemas) {
    $path = Join-Path $objectsRoot "schemas\$schema"
    if (Test-Path -LiteralPath $path) {
        $schemaCoverage.ownedSchemas += $schema
    } else {
        $schemaCoverage.missingOwnedSchemas += $schema
        Add-Failure "Missing object-source folder for owned schema: $schema"
    }
}
foreach ($schema in $excludedSchemas) {
    $path = Join-Path $objectsRoot "schemas\$schema"
    if (Test-Path -LiteralPath $path) {
        $schemaCoverage.excludedSchemaFoldersPresent += $schema
        Add-Failure "Excluded schema is represented as ExitPass-owned object source: $schema"
    }
}
$extensionPath = Join-Path $objectsRoot 'extensions\public.pgcrypto.sql'
if (Test-Path -LiteralPath $extensionPath) {
    $schemaCoverage.extensionObjects += 'objects/extensions/public.pgcrypto.sql'
} else {
    Add-Failure 'Missing extension object source: objects/extensions/public.pgcrypto.sql'
}

$counts = [ordered]@{}
foreach ($category in @('schema','types','tables','constraints','indexes','functions','triggers','views','comments')) {
    $categoryCount = (Get-ChildItem -Path (Join-Path $objectsRoot 'schemas') -Recurse -Directory -Filter $category -ErrorAction SilentlyContinue |
        ForEach-Object { Get-ChildItem -Path $_.FullName -File -Filter *.sql -ErrorAction SilentlyContinue } |
        Measure-Object).Count
    $counts[$category] = $categoryCount
}
$counts['extensions'] = (Get-ChildItem -Path (Join-Path $objectsRoot 'extensions') -File -Filter *.sql -ErrorAction SilentlyContinue | Measure-Object).Count
$counts['referenceData'] = (Get-ChildItem -Path (Join-Path $objectsRoot 'reference-data') -File -Filter *.sql -ErrorAction SilentlyContinue | Measure-Object).Count
$counts['uat'] = (Get-ChildItem -Path (Join-Path $objectsRoot 'uat') -File -Filter *.sql -ErrorAction SilentlyContinue | Measure-Object).Count
$counts['totalObjectFiles'] = (Get-ChildItem -Path $objectsRoot -Recurse -File -Filter *.sql -ErrorAction SilentlyContinue | Measure-Object).Count

$allObjectFiles = @(Get-ChildItem -Path $objectsRoot -Recurse -File -Filter *.sql -ErrorAction SilentlyContinue | ForEach-Object { ConvertTo-RepoPath $_.FullName } | Sort-Object)
$applyOrderSpecs = @(
    [ordered]@{ name = 'full'; path = 'objects/exitpass-full-object-apply-order.txt'; allowOmittedPattern = '^objects/uat/' },
    [ordered]@{ name = 'v13-central-pms'; path = 'objects/v13-central-pms-object-apply-order.txt'; scoped = $true },
    [ordered]@{ name = 'v13-central-pms-uat'; path = 'objects/v13-central-pms-uat-object-apply-order.txt'; scoped = $true }
)
$applyOrderResults = @()
foreach ($spec in $applyOrderSpecs) {
    $applyOrderPath = Join-Path $RepoRoot ($spec.path -replace '/', [IO.Path]::DirectorySeparatorChar)
    $entries = @()
    $missingFiles = @()
    $duplicates = @()
    $unexpectedSourceEntries = @()
    $omittedFiles = @()
    $allowedOmittedFiles = @()

    if (-not (Test-Path -LiteralPath $applyOrderPath)) {
        Add-Failure "Missing apply-order file: $($spec.path)"
    } else {
        $entries = Get-ApplyOrderEntries $applyOrderPath
        $duplicates = @($entries | Group-Object | Where-Object Count -gt 1 | ForEach-Object { $_.Name })
        foreach ($duplicate in $duplicates) { Add-Failure "Duplicate entry in $($spec.path): $duplicate" }
        foreach ($entry in $entries) {
            $entryFullPath = Join-Path $RepoRoot ($entry -replace '/', [IO.Path]::DirectorySeparatorChar)
            if (-not (Test-Path -LiteralPath $entryFullPath)) {
                $missingFiles += $entry
                Add-Failure "Apply-order entry does not exist in $($spec.path): $entry"
            }
            if ($entry -match '^(build|migrations|schema)/') {
                $unexpectedSourceEntries += $entry
                Add-Failure "Apply-order lists a generated/migration/baseline file instead of object source in $($spec.path): $entry"
            }
        }

        if ($spec.name -eq 'full') {
            foreach ($file in $allObjectFiles) {
                if ($entries -notcontains $file) {
                    if ($file -match $spec.allowOmittedPattern) {
                        $allowedOmittedFiles += $file
                    } else {
                        $omittedFiles += $file
                        Add-Failure "Full apply-order omits object source file: $file"
                    }
                }
            }
        }
    }

    $applyOrderResults += [ordered]@{
        name = $spec.name
        path = $spec.path
        entryCount = $entries.Count
        missingFiles = $missingFiles
        duplicateEntries = $duplicates
        unexpectedSourceEntries = $unexpectedSourceEntries
        omittedFiles = $omittedFiles
        explicitlyAllowedOmissions = $allowedOmittedFiles
    }
}

$generatedResults = [ordered]@{
    generatedFiles = @()
    stableAfterRegeneration = $true
    freshnessFailures = @()
}
$generatedSpecs = @(
    [ordered]@{ name = 'full'; path = 'build/generated/exitpass-full-object.generated.sql'; builder = 'scripts/build/Build-ExitPassFullObjectSql.ps1'; header = 'ExitPass full database generated from object source files.' },
    [ordered]@{ name = 'v13-central-pms'; path = 'build/generated/v13-central-pms-alignment.generated.sql'; builder = 'scripts/build/Build-V13CentralPmsObjectSql.ps1'; header = 'ExitPass v1.3 Central PMS alignment generated from object source files.' }
)
foreach ($spec in $generatedSpecs) {
    $generatedPath = Join-Path $RepoRoot ($spec.path -replace '/', [IO.Path]::DirectorySeparatorChar)
    $builderPath = Join-Path $RepoRoot ($spec.builder -replace '/', [IO.Path]::DirectorySeparatorChar)
    $before = $null
    if (Test-Path -LiteralPath $generatedPath) { $before = Get-Content -LiteralPath $generatedPath -Raw }
    & $builderPath -RepoRoot $RepoRoot
    if (-not (Test-Path -LiteralPath $generatedPath)) {
        Add-Failure "Generated SQL was not produced: $($spec.path)"
        continue
    }
    $after = Get-Content -LiteralPath $generatedPath -Raw
    $hasHeader = ($after.Contains('<auto-generated>') -and $after.Contains($spec.header))
    if (-not $hasHeader) { Add-Failure "Generated SQL missing expected generated header: $($spec.path)" }
    $isStable = ($null -ne $before -and $before -ceq $after)
    if (-not $isStable) {
        $generatedResults.stableAfterRegeneration = $false
        $generatedResults.freshnessFailures += $spec.path
        Add-Failure "Generated SQL changed after regeneration; commit regenerated artifact: $($spec.path)"
    }
    $generatedResults.generatedFiles += [ordered]@{
        name = $spec.name
        path = $spec.path
        hasExpectedHeader = $hasHeader
        stableAfterRegeneration = $isStable
        lengthBytes = (Get-Item -LiteralPath $generatedPath).Length
    }
}

$fullGenerated = Join-Path $RepoRoot 'build\generated\exitpass-full-object.generated.sql'
$fullSql = if (Test-Path -LiteralPath $fullGenerated) { Get-Content -LiteralPath $fullGenerated -Raw } else { '' }
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
    'audit.audit_events',
    'integration.vendor_systems',
    'config.controlled_code_sets',
    'events.outbox_events',
    'core.fiscal_issuance_references',
    'discounts.statutory_discount_payable_basis_applications',
    'discounts.apply_statutory_discount_payable_basis',
    'operator_console.operator_device_bindings',
    'operator_console.operator_shifts',
    'management-platform.identity-rbac.inventory.read'
)
$presence = @()
foreach ($marker in $requiredMarkers) {
    $found = Test-GeneratedMarker -Sql $fullSql -Marker $marker
    if (-not $found) { Add-Failure "Generated SQL missing required object/marker: $marker" }
    $presence += [ordered]@{ marker = $marker; found = $found }
}

$dbApply = [ordered]@{ requested = [bool]$RunDbApply; skipped = -not [bool]$RunDbApply; result = if ($RunDbApply) { 'NOT_RUN' } else { 'SKIPPED' }; mode = if ([string]::IsNullOrWhiteSpace($DbHost)) { 'docker-exec' } else { 'psql' }; host = if ([string]::IsNullOrWhiteSpace($DbHost)) { $null } else { $DbHost }; port = if ([string]::IsNullOrWhiteSpace($DbHost)) { $null } else { $DbPort }; adminDatabase = $AdminDatabase; database = $ValidationDatabase; notes = @() }
if ($RunDbApply) {
    try {
        if ($ValidationDatabase -notmatch '^[A-Za-z0-9_]+$') { throw "Validation database name is not safe for scripted creation: $ValidationDatabase" }
        $alignmentScript = Join-Path $RepoRoot 'scripts\validation\Validate-V13CentralPmsAlignment.sql'
        if ([string]::IsNullOrWhiteSpace($DbHost)) {
            $docker = Get-Command docker -ErrorAction Stop
            $containerProbe = & docker ps --format '{{.Names}}' 2>$null
            if ($containerProbe -notcontains $DockerContainer) {
                throw "Docker container is not running or not found: $DockerContainer"
            }
            & docker exec $DockerContainer psql -v ON_ERROR_STOP=1 -U $DbUser -d $AdminDatabase -c "DROP DATABASE IF EXISTS $ValidationDatabase;"
            & docker exec $DockerContainer psql -v ON_ERROR_STOP=1 -U $DbUser -d $AdminDatabase -c "CREATE DATABASE $ValidationDatabase;"
            & docker cp $fullGenerated "$DockerContainer`:/tmp/exitpass-full-object.generated.sql"
            & docker exec $DockerContainer psql -v ON_ERROR_STOP=1 -U $DbUser -d $ValidationDatabase -f /tmp/exitpass-full-object.generated.sql
            & docker cp $alignmentScript "$DockerContainer`:/tmp/Validate-V13CentralPmsAlignment.sql"
            & docker exec $DockerContainer psql -v ON_ERROR_STOP=1 -U $DbUser -d $ValidationDatabase -f /tmp/Validate-V13CentralPmsAlignment.sql
        } else {
            $psql = Get-Command psql -ErrorAction Stop
            $previousPassword = $env:PGPASSWORD
            if (-not [string]::IsNullOrWhiteSpace($DbPassword)) { $env:PGPASSWORD = $DbPassword }
            try {
                & psql -h $DbHost -p $DbPort -U $DbUser -d $AdminDatabase -v ON_ERROR_STOP=1 -c "DROP DATABASE IF EXISTS $ValidationDatabase;"
                & psql -h $DbHost -p $DbPort -U $DbUser -d $AdminDatabase -v ON_ERROR_STOP=1 -c "CREATE DATABASE $ValidationDatabase;"
                & psql -h $DbHost -p $DbPort -U $DbUser -d $ValidationDatabase -v ON_ERROR_STOP=1 -f $fullGenerated
                & psql -h $DbHost -p $DbPort -U $DbUser -d $ValidationDatabase -v ON_ERROR_STOP=1 -f $alignmentScript
            } finally {
                $env:PGPASSWORD = $previousPassword
            }
        }
        $dbApply.result = 'PASSED'
        $dbApply.skipped = $false
    } catch {
        $dbApply.result = 'FAILED'
        $dbApply.skipped = $false
        $dbApply.notes += $_.Exception.Message
        Add-Failure "Disposable DB apply failed: $($_.Exception.Message)"
    }
}

$result = if ($failures.Count -eq 0) { 'PASSED' } else { 'FAILED' }
$report = [ordered]@{
    result = $result
    generatedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
    branch = $branch
    repoRoot = $RepoRoot
    schemaCoverage = $schemaCoverage
    objectCounts = $counts
    applyOrders = $applyOrderResults
    generatedSql = $generatedResults
    requiredObjectPresence = $presence
    dbApply = $dbApply
    failures = @($failures)
}

$jsonPath = Join-Path $outputRoot 'db-object-source-coverage.json'
$mdPath = Join-Path $outputRoot 'db-object-source-coverage.md'
$report | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $jsonPath -Encoding UTF8

$md = New-Object System.Text.StringBuilder
[void]$md.AppendLine('# ExitPass DB Object Source Coverage Report')
[void]$md.AppendLine()
[void]$md.AppendLine("Result: **$result**")
[void]$md.AppendLine()
[void]$md.AppendLine('Generated at UTC: `' + $report.generatedAtUtc + '`')
[void]$md.AppendLine('Branch: `' + $branch + '`')
[void]$md.AppendLine()
[void]$md.AppendLine('## Object Counts')
[void]$md.AppendLine()
[void]$md.AppendLine('| Type | Count |')
[void]$md.AppendLine('| --- | ---: |')
foreach ($entry in $counts.GetEnumerator()) { [void]$md.AppendLine("| $($entry.Key) | $($entry.Value) |") }
[void]$md.AppendLine()
[void]$md.AppendLine('## Apply Orders')
[void]$md.AppendLine()
[void]$md.AppendLine('| Name | Entries | Missing | Duplicates | Omitted | Explicit omissions |')
[void]$md.AppendLine('| --- | ---: | ---: | ---: | ---: | ---: |')
foreach ($order in $applyOrderResults) {
    [void]$md.AppendLine("| $($order.name) | $($order.entryCount) | $($order.missingFiles.Count) | $($order.duplicateEntries.Count) | $($order.omittedFiles.Count) | $($order.explicitlyAllowedOmissions.Count) |")
}
[void]$md.AppendLine()
[void]$md.AppendLine('## Generated SQL')
[void]$md.AppendLine()
[void]$md.AppendLine('| Artifact | Header | Stable after regeneration | Bytes |')
[void]$md.AppendLine('| --- | --- | --- | ---: |')
foreach ($artifact in $generatedResults.generatedFiles) {
    [void]$md.AppendLine('| `' + $artifact.path + '` | ' + $artifact.hasExpectedHeader + ' | ' + $artifact.stableAfterRegeneration + ' | ' + $artifact.lengthBytes + ' |')
}
[void]$md.AppendLine()
[void]$md.AppendLine('## Required Markers')
[void]$md.AppendLine()
[void]$md.AppendLine('| Marker | Found |')
[void]$md.AppendLine('| --- | --- |')
foreach ($item in $presence) { [void]$md.AppendLine('| `' + $item.marker + '` | ' + $item.found + ' |') }
[void]$md.AppendLine()
[void]$md.AppendLine('## DB Apply')
[void]$md.AppendLine()
[void]$md.AppendLine('Requested: `' + $dbApply.requested + '`')
[void]$md.AppendLine('Result: `' + $dbApply.result + '`')
[void]$md.AppendLine('Database: `' + $dbApply.database + '`')
[void]$md.AppendLine()
[void]$md.AppendLine('## Failures')
[void]$md.AppendLine()
if ($failures.Count -eq 0) {
    [void]$md.AppendLine('None.')
} else {
    foreach ($failure in $failures) { [void]$md.AppendLine("- $failure") }
}
Set-Content -LiteralPath $mdPath -Value $md.ToString() -Encoding UTF8

Write-Host "DB object-source coverage report result: $result"
Write-Host "JSON report: $jsonPath"
Write-Host "Markdown report: $mdPath"
if ($failures.Count -gt 0) {
    throw ('DB object-source coverage report failed: ' + ($failures -join '; '))
}
