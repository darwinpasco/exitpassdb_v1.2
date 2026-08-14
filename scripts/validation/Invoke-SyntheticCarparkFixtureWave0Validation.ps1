[CmdletBinding()]
param(
    [string]$RepositoryRoot,
    [string]$BaselineRef = 'origin/develop',
    [string]$ReportPath = 'build\reports\synthetic-carpark-fixture-wave0-report.txt',
    [string]$PostgresImage = 'postgres:16-alpine'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}
$RepositoryRoot = (Resolve-Path -LiteralPath $RepositoryRoot).Path

function Assert-Condition {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

function Invoke-NativeCommand {
    param(
        [string]$FilePath,
        [string[]]$Arguments,
        [string]$FailureMessage
    )

    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = @(& $FilePath @Arguments 2>&1 | ForEach-Object { $_.ToString() })
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }
    if ($exitCode -ne 0) {
        $diagnostic = ($output | Select-Object -Last 12) -join [Environment]::NewLine
        throw "$FailureMessage (exit $exitCode).`n$diagnostic"
    }
    return $output
}

function New-SecureHex {
    param([int]$ByteCount)

    $bytes = New-Object byte[] $ByteCount
    $generator = [Security.Cryptography.RandomNumberGenerator]::Create()
    try { $generator.GetBytes($bytes) } finally { $generator.Dispose() }
    return (($bytes | ForEach-Object { $_.ToString('x2') }) -join '')
}

function Get-Sha256Hex {
    param([byte[]]$Bytes)

    $sha = [Security.Cryptography.SHA256]::Create()
    try { $hash = $sha.ComputeHash($Bytes) } finally { $sha.Dispose() }
    return (($hash | ForEach-Object { $_.ToString('x2') }) -join '')
}

function Get-Wave0ChangedPaths {
    param([string]$Root, [string]$BaseRef)

    [void](Invoke-NativeCommand git @('-C', $Root, 'rev-parse', '--verify', $BaseRef) "Baseline ref $BaseRef is unavailable")
    $paths = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    $commands = @(
        @('-C', $Root, 'diff', '--name-only', "$BaseRef...HEAD"),
        @('-C', $Root, 'diff', '--name-only'),
        @('-C', $Root, 'diff', '--cached', '--name-only'),
        @('-C', $Root, 'ls-files', '--others', '--exclude-standard')
    )
    foreach ($arguments in $commands) {
        foreach ($path in Invoke-NativeCommand git $arguments 'Git changed-path inventory failed') {
            if (-not [string]::IsNullOrWhiteSpace($path)) { [void]$paths.Add($path.Replace('\', '/')) }
        }
    }
    return @($paths | Sort-Object)
}

function Test-TrackedSourceOccurrences {
    param([string]$Root)

    $dataRoot = Join-Path $Root 'docs\v1.3\reference-data\data'
    $inventoryPath = Join-Path $dataRoot 'ExitPass_Synthetic_Carpark_Fixture_Tracked_Source_Occurrence_Inventory_v1.0.csv'
    $expectedRows = @(Import-Csv -LiteralPath $inventoryPath | Where-Object { $_.repository -eq 'exitpassdb_v1.2' })
    Assert-Condition ($expectedRows.Count -gt 0) 'The repository occurrence baseline is empty.'
    Assert-Condition (@($expectedRows | Where-Object { -not $_.reference_type -or -not $_.path -or -not $_.classification_basis }).Count -eq 0) 'A baseline tracked-source occurrence is unclassified.'

    $tokens = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
    foreach ($row in $expectedRows) {
        foreach ($token in $row.matched_fixture_tokens.Split(';')) {
            if (-not [string]::IsNullOrWhiteSpace($token)) { [void]$tokens.Add($token.Trim()) }
        }
    }

    $packageExclusions = @(
        'docs/v1.3/reference-data/ExitPass_Synthetic_Carpark_Fixture_Reconciliation_and_Migration_Plan_v1.0.md',
        'docs/v1.3/reference-data/data/ExitPass_Synthetic_Carpark_Fixture_Dependent_Reference_Inventory_v1.0.csv',
        'docs/v1.3/reference-data/data/ExitPass_Synthetic_Carpark_Fixture_Tracked_Source_Occurrence_Inventory_v1.0.csv',
        'docs/v1.3/reference-data/data/ExitPass_Synthetic_Site_Fixture_Inventory_v1.0.csv',
        'docs/v1.3/reference-data/data/ExitPass_Synthetic_Site_Group_Fixture_Inventory_v1.0.csv',
        'docs/v1.3/reference-data/data/ExitPass_Synthetic_Site_Jurisdiction_Assignment_Inventory_v1.0.csv',
        'docs/v1.3/reference-data/data/ExitPass_Synthetic_to_Realistic_Identity_Reconciliation_v1.0.csv',
        'scripts/validation/Analyze-SyntheticCarparkFixtureDependencies.sql',
        'scripts/validation/Test-SyntheticCarparkFixtureReconciliationPlan.ps1',
        'scripts/validation/Validate-SyntheticCarparkFixtureReconciliation.sql'
    )
    $expectedPaths = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    foreach ($row in $expectedRows) { [void]$expectedPaths.Add($row.path.Replace('\', '/')) }
    $actualPaths = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    $candidateFiles = @(Invoke-NativeCommand git @('-C', $Root, 'ls-files', '--cached', '--others', '--exclude-standard') 'Tracked source inventory failed')

    foreach ($relativePath in $candidateFiles) {
        $normalizedPath = $relativePath.Replace('\', '/')
        if ($normalizedPath -in $packageExclusions) { continue }
        $fullPath = Join-Path $Root ($normalizedPath.Replace('/', [IO.Path]::DirectorySeparatorChar))
        if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) { continue }
        try { $text = [IO.File]::ReadAllText($fullPath) } catch { continue }
        foreach ($token in $tokens) {
            if ($text.Contains($token)) {
                [void]$actualPaths.Add($normalizedPath)
                break
            }
        }
    }

    $missing = @($expectedPaths | Where-Object { -not $actualPaths.Contains($_) } | Sort-Object)
    $unexpected = @($actualPaths | Where-Object { -not $expectedPaths.Contains($_) } | Sort-Object)
    Assert-Condition ($missing.Count -eq 0) ("Tracked fixture occurrences disappeared without inventory reconciliation: " + ($missing -join ', '))
    Assert-Condition ($unexpected.Count -eq 0) ("New tracked fixture occurrences require classification: " + ($unexpected -join ', '))
    return $actualPaths.Count
}

function ConvertFrom-PsqlCsv {
    param([string[]]$Lines)
    $content = @($Lines | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }) -join [Environment]::NewLine
    if ([string]::IsNullOrWhiteSpace($content)) { return @() }
    return @($content | ConvertFrom-Csv)
}

function Compare-FixtureRows {
    param(
        [object[]]$Expected,
        [object[]]$Actual,
        [string[]]$Columns,
        [string]$Label
    )

    $expectedById = @{}
    foreach ($row in $Expected) { $expectedById[$row.fixture_id] = $row }
    $actualById = @{}
    foreach ($row in $Actual) {
        Assert-Condition (-not $actualById.ContainsKey($row.fixture_id)) "$Label contains duplicate identity $($row.fixture_id)."
        $actualById[$row.fixture_id] = $row
    }
    $missing = @($expectedById.Keys | Where-Object { -not $actualById.ContainsKey($_) } | Sort-Object)
    $unexpected = @($actualById.Keys | Where-Object { -not $expectedById.ContainsKey($_) } | Sort-Object)
    Assert-Condition ($missing.Count -eq 0) ("$Label missing approved identities: " + ($missing -join ', '))
    Assert-Condition ($unexpected.Count -eq 0) ("$Label contains unclassified identities: " + ($unexpected -join ', '))
    foreach ($id in $expectedById.Keys) {
        foreach ($column in $Columns) {
            $expectedValue = [string]$expectedById[$id].$column
            $actualValue = [string]$actualById[$id].$column
            Assert-Condition ($expectedValue -ceq $actualValue) "$Label identity $id changed $column from '$expectedValue' to '$actualValue'."
        }
    }
}

function Test-DockerResourceIdentity {
    param(
        [ValidateSet('container','network','volume')][string]$Type,
        [string]$Name,
        [string]$ExpectedIdentity,
        [string]$RunId
    )

    $json = @(Invoke-NativeCommand docker @($Type, 'inspect', $Name) "Cannot revalidate owned Docker $Type $Name") -join "`n"
    $resource = @($json | ConvertFrom-Json)[0]
    switch ($Type) {
        'container' { $actualIdentity = $resource.Id; $actualRunId = $resource.Config.Labels.'com.exitpass.wave0.run-id' }
        'network' { $actualIdentity = $resource.Id; $actualRunId = $resource.Labels.'com.exitpass.wave0.run-id' }
        'volume' { $actualIdentity = $resource.Name; $actualRunId = $resource.Labels.'com.exitpass.wave0.run-id' }
    }
    Assert-Condition ($actualIdentity -eq $ExpectedIdentity -and $actualRunId -eq $RunId) "Docker $Type ownership changed for $Name."
}

function Get-InvocationOwnedDockerIdentityIfPresent {
    param(
        [ValidateSet('container','network','volume')][string]$Type,
        [string]$Name,
        [string]$RunId
    )

    switch ($Type) {
        'container' { $names = @(Invoke-NativeCommand docker @('container','ls','--all','--format','{{.Names}}') 'Docker container cleanup inventory failed') }
        'network' { $names = @(Invoke-NativeCommand docker @('network','ls','--format','{{.Name}}') 'Docker network cleanup inventory failed') }
        'volume' { $names = @(Invoke-NativeCommand docker @('volume','ls','--format','{{.Name}}') 'Docker volume cleanup inventory failed') }
    }
    if ($Name -notin $names) { return $null }

    $json = @(Invoke-NativeCommand docker @($Type, 'inspect', $Name) "Cannot inspect partially created Docker $Type $Name") -join "`n"
    $resource = @($json | ConvertFrom-Json)[0]
    switch ($Type) {
        'container' { $identity = $resource.Id; $actualRunId = $resource.Config.Labels.'com.exitpass.wave0.run-id' }
        'network' { $identity = $resource.Id; $actualRunId = $resource.Labels.'com.exitpass.wave0.run-id' }
        'volume' { $identity = $resource.Name; $actualRunId = $resource.Labels.'com.exitpass.wave0.run-id' }
    }
    Assert-Condition ($actualRunId -eq $RunId) "Partially created Docker $Type $Name is not owned by this invocation."
    return $identity
}

$reportLines = New-Object 'System.Collections.Generic.List[string]'
$reportLines.Add('WAVE0_SYNTHETIC_CARPARK_FIXTURE_REPORT_V1')
$reportLines.Add('BASELINE_REF=' + $BaselineRef)
$failure = $null
$temporaryRoot = $null
$containerCreated = $false
$networkCreated = $false
$volumeCreated = $false
$containerIdentity = $null
$networkIdentity = $null
$volumeIdentity = $null
$suffix = New-SecureHex 6
$runId = New-SecureHex 16
$containerName = "exitpass-wave0-pg-$suffix"
$networkName = "exitpass-wave0-net-$suffix"
$volumeName = "exitpass-wave0-vol-$suffix"
$databaseName = "exitpass_fixture_wave0_$suffix"

try {
    $changedPaths = @(Get-Wave0ChangedPaths -Root $RepositoryRoot -BaseRef $BaselineRef)
    $harnessPath = Join-Path $RepositoryRoot 'scripts\validation\Test-SyntheticCarparkFixtureReconciliationPlan.ps1'
    & $harnessPath -RepositoryRoot $RepositoryRoot -RunNegativeTests -ChangedPaths $changedPaths
    $trackedOccurrenceCount = Test-TrackedSourceOccurrences -Root $RepositoryRoot

    & (Join-Path $RepositoryRoot 'scripts\build\Build-ExitPassFullObjectSql.ps1') -RepoRoot $RepositoryRoot
    $generatedDiff = @(Invoke-NativeCommand git @('-C', $RepositoryRoot, 'diff', '--name-only', '--', 'build/generated/exitpass-full-object.generated.sql') 'Generated SQL equivalence check failed')
    Assert-Condition ($generatedDiff.Count -eq 0) 'Canonical generated SQL changed during Wave 0 validation.'

    $containerNames = @(Invoke-NativeCommand docker @('container','ls','--all','--format','{{.Names}}') 'Docker container inventory failed')
    $networkNames = @(Invoke-NativeCommand docker @('network','ls','--format','{{.Name}}') 'Docker network inventory failed')
    $volumeNames = @(Invoke-NativeCommand docker @('volume','ls','--format','{{.Name}}') 'Docker volume inventory failed')
    Assert-Condition ($containerName -notin $containerNames -and $networkName -notin $networkNames -and $volumeName -notin $volumeNames) 'A generated Wave 0 Docker resource name already exists.'

    $networkOutput = @(Invoke-NativeCommand docker @('network','create','--label',"com.exitpass.wave0.run-id=$runId",$networkName) 'Wave 0 Docker network creation failed')
    $networkCreated = $true
    Assert-Condition ($networkOutput.Count -eq 1) 'Wave 0 Docker network creation returned an ambiguous identity.'
    $networkIdentity = $networkOutput[0].ToString().Trim()
    $volumeOutput = @(Invoke-NativeCommand docker @('volume','create','--label',"com.exitpass.wave0.run-id=$runId",$volumeName) 'Wave 0 Docker volume creation failed')
    $volumeCreated = $true
    Assert-Condition ($volumeOutput.Count -eq 1) 'Wave 0 Docker volume creation returned an ambiguous identity.'
    $volumeIdentity = $volumeOutput[0].ToString().Trim()
    $containerOutput = @(Invoke-NativeCommand docker @('run','--detach','--name',$containerName,'--network',$networkName,'--mount',"source=$volumeName,target=/var/lib/postgresql/data",'--label',"com.exitpass.wave0.run-id=$runId",'--env','POSTGRES_HOST_AUTH_METHOD=trust','--env',"POSTGRES_DB=$databaseName",$PostgresImage) 'Wave 0 PostgreSQL container creation failed')
    $containerCreated = $true
    Assert-Condition ($containerOutput.Count -eq 1) 'Wave 0 Docker container creation returned an ambiguous identity.'
    $containerIdentity = $containerOutput[0].ToString().Trim()

    $ready = $false
    for ($attempt = 0; $attempt -lt 60; $attempt++) {
        $previousPreference = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try { & docker exec $containerName pg_isready -U postgres -d $databaseName *> $null; $readyExit = $LASTEXITCODE } finally { $ErrorActionPreference = $previousPreference }
        if ($readyExit -eq 0) { $ready = $true; break }
        Start-Sleep -Milliseconds 500
    }
    Assert-Condition $ready 'Wave 0 PostgreSQL did not become ready.'

    $temporaryRoot = Join-Path ([IO.Path]::GetTempPath()) ("exitpass-wave0-$suffix")
    [IO.Directory]::CreateDirectory($temporaryRoot) | Out-Null
    $filesToCopy = [ordered]@{
        (Join-Path $RepositoryRoot 'build\generated\exitpass-full-object.generated.sql') = '/tmp/full.sql'
        (Join-Path $RepositoryRoot 'scripts\validation\Validate-RealisticCarparkCatalog.sql') = '/tmp/realistic.sql'
        (Join-Path $RepositoryRoot 'scripts\validation\Analyze-SyntheticCarparkFixtureDependencies.sql') = '/tmp/analyze.sql'
        (Join-Path $RepositoryRoot 'scripts\validation\Validate-SyntheticCarparkFixtureReconciliation.sql') = '/tmp/reconcile.sql'
    }
    foreach ($entry in $filesToCopy.GetEnumerator()) {
        [void](Invoke-NativeCommand docker @('cp',$entry.Key,"$containerName`:$($entry.Value)") "Cannot copy Wave 0 SQL $($entry.Key)")
    }
    foreach ($sqlPath in @('/tmp/full.sql','/tmp/realistic.sql')) {
        [void](Invoke-NativeCommand docker @('exec',$containerName,'psql','-X','-q','-v','ON_ERROR_STOP=1','-U','postgres','-d',$databaseName,'-f',$sqlPath) "Wave 0 SQL execution failed for $sqlPath")
    }
    $analyzerOutput = @(Invoke-NativeCommand docker @('exec',$containerName,'psql','-X','-q','-A','-F','|','-P','footer=off','-v','ON_ERROR_STOP=1','-U','postgres','-d',$databaseName,'-f','/tmp/analyze.sql') 'Wave 0 dependency analyzer failed')
    [void](Invoke-NativeCommand docker @('exec',$containerName,'psql','-X','-q','-v','ON_ERROR_STOP=1','-U','postgres','-d',$databaseName,'-f','/tmp/reconcile.sql') 'Wave 0 reconciliation SQL validation failed')

    $dataRoot = Join-Path $RepositoryRoot 'docs\v1.3\reference-data\data'
    $expectedGroups = @(Import-Csv (Join-Path $dataRoot 'ExitPass_Synthetic_Site_Group_Fixture_Inventory_v1.0.csv') | Where-Object catalog_presence -eq 'CANONICAL_CLEAN_BUILD')
    $expectedSites = @(Import-Csv (Join-Path $dataRoot 'ExitPass_Synthetic_Site_Fixture_Inventory_v1.0.csv') | Where-Object catalog_presence -eq 'CANONICAL_CLEAN_BUILD')
    $expectedAssignments = @(Import-Csv (Join-Path $dataRoot 'ExitPass_Synthetic_Site_Jurisdiction_Assignment_Inventory_v1.0.csv') | Where-Object catalog_presence -eq 'CANONICAL_CLEAN_BUILD')
    $mappingRows = @(Import-Csv (Join-Path $dataRoot 'ExitPass_Synthetic_to_Realistic_Identity_Reconciliation_v1.0.csv'))
    $dependencyRows = @(Import-Csv (Join-Path $dataRoot 'ExitPass_Synthetic_Carpark_Fixture_Dependent_Reference_Inventory_v1.0.csv'))

    foreach ($id in @($expectedGroups.fixture_id) + @($expectedSites.fixture_id) + @($expectedAssignments.fixture_id)) {
        $parsedId = [guid]::Empty
        Assert-Condition ([guid]::TryParse($id, [ref]$parsedId)) "Fixture inventory contains a malformed UUID: $id"
    }
    $groupIdList = (@($expectedGroups.fixture_id | ForEach-Object { "'$_'::uuid" }) -join ',')
    $siteIdList = (@($expectedSites.fixture_id | ForEach-Object { "'$_'::uuid" }) -join ',')
    $groupQuery = "SELECT site_group_id::text AS fixture_id, site_group_code AS fixture_code, site_group_name AS fixture_name, site_group_status::text AS current_status, public_lookup_enabled::text, default_payment_enabled::text AS payment_enabled FROM sites.site_groups WHERE site_group_id IN ($groupIdList) ORDER BY site_group_id;"
    $siteQuery = "SELECT s.site_id::text AS fixture_id, s.site_group_id::text, sg.site_group_code, s.site_code AS fixture_code, s.site_name AS fixture_name, s.site_type::text, COALESCE(s.lgu_code,'') AS lgu_code, s.site_status::text AS current_status, s.public_lookup_enabled::text, s.payment_enabled::text FROM sites.sites s JOIN sites.site_groups sg ON sg.site_group_id=s.site_group_id WHERE s.site_group_id IN ($groupIdList) ORDER BY s.site_id;"
    $assignmentQuery = "SELECT a.site_jurisdiction_assignment_id::text AS fixture_id, a.site_id::text, a.jurisdiction_id::text, a.assignment_status::text AS current_status, to_char(a.effective_from AT TIME ZONE 'UTC','YYYY-MM-DD HH24:MI:SS') || '+00' AS effective_from, COALESCE(to_char(a.effective_to AT TIME ZONE 'UTC','YYYY-MM-DD HH24:MI:SS') || '+00','') AS effective_to FROM sites.site_jurisdiction_assignments a WHERE a.site_id IN ($siteIdList) ORDER BY a.site_jurisdiction_assignment_id;"
    $actualGroups = ConvertFrom-PsqlCsv (Invoke-NativeCommand docker @('exec',$containerName,'psql','-X','-q','--csv','-U','postgres','-d',$databaseName,'-c',$groupQuery) 'Wave 0 Site Group inventory query failed')
    $actualSites = ConvertFrom-PsqlCsv (Invoke-NativeCommand docker @('exec',$containerName,'psql','-X','-q','--csv','-U','postgres','-d',$databaseName,'-c',$siteQuery) 'Wave 0 Site inventory query failed')
    $actualAssignments = ConvertFrom-PsqlCsv (Invoke-NativeCommand docker @('exec',$containerName,'psql','-X','-q','--csv','-U','postgres','-d',$databaseName,'-c',$assignmentQuery) 'Wave 0 assignment inventory query failed')
    Compare-FixtureRows $expectedGroups $actualGroups @('fixture_code','fixture_name','current_status','public_lookup_enabled','payment_enabled') 'Site Group fixture inventory'
    Compare-FixtureRows $expectedSites $actualSites @('site_group_id','site_group_code','fixture_code','fixture_name','site_type','lgu_code','current_status','public_lookup_enabled','payment_enabled') 'Site fixture inventory'
    Compare-FixtureRows $expectedAssignments $actualAssignments @('site_id','jurisdiction_id','current_status','effective_from','effective_to') 'Assignment fixture inventory'

    $targetQuery = "SELECT 'SITE_GROUP' AS target_type, site_group_id::text AS target_id FROM sites.site_groups UNION ALL SELECT 'SITE', site_id::text FROM sites.sites;"
    $targetRows = ConvertFrom-PsqlCsv (Invoke-NativeCommand docker @('exec',$containerName,'psql','-X','-q','--csv','-U','postgres','-d',$databaseName,'-c',$targetQuery) 'Wave 0 realistic-target query failed')
    $targetKeys = @{}; foreach ($row in $targetRows) { $targetKeys[($row.target_type + '|' + $row.target_id)] = $true }
    foreach ($mapping in $mappingRows | Where-Object realistic_target_id) {
        Assert-Condition $targetKeys.ContainsKey(($mapping.realistic_target_type + '|' + $mapping.realistic_target_id)) "Approved mapping target is missing: $($mapping.realistic_target_type) $($mapping.realistic_target_id)."
    }

    $fkQuery = "SELECT n1.nspname AS schema, c1.relname AS table, string_agg(a1.attname,',' ORDER BY k.ord) AS column, con.conname AS constraint FROM pg_constraint con JOIN pg_class c1 ON c1.oid=con.conrelid JOIN pg_namespace n1 ON n1.oid=c1.relnamespace JOIN LATERAL unnest(con.conkey) WITH ORDINALITY k(attnum,ord) ON true JOIN pg_attribute a1 ON a1.attrelid=c1.oid AND a1.attnum=k.attnum WHERE con.contype='f' AND con.confrelid IN ('sites.site_groups'::regclass,'sites.sites'::regclass,'sites.site_jurisdiction_assignments'::regclass) GROUP BY n1.nspname,c1.relname,con.conname ORDER BY n1.nspname,c1.relname,con.conname;"
    $actualFks = ConvertFrom-PsqlCsv (Invoke-NativeCommand docker @('exec',$containerName,'psql','-X','-q','--csv','-U','postgres','-d',$databaseName,'-c',$fkQuery) 'Wave 0 foreign-key inventory query failed')
    $expectedFkKeys = @($dependencyRows | Where-Object reference_scope -eq 'DECLARED_FK_CATALOG' | ForEach-Object { "$($_.schema)|$($_.table)|$($_.column)|$($_.constraint)" } | Sort-Object -Unique)
    $actualFkKeys = @($actualFks | ForEach-Object { "$($_.schema)|$($_.table)|$($_.column)|$($_.constraint)" } | Sort-Object -Unique)
    Assert-Condition (($expectedFkKeys -join "`n") -ceq ($actualFkKeys -join "`n")) 'Declared fixture dependency boundaries differ from the approved inventory.'

    $allowedReferenceKeys = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    foreach ($row in $dependencyRows) {
        foreach ($column in $row.column.Split(',')) {
            if ($row.schema -and $row.table -and $column) { [void]$allowedReferenceKeys.Add("$($row.schema).$($row.table)|$($column.Trim())") }
        }
    }
    $observedReferenceKeys = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    foreach ($line in $analyzerOutput) {
        $parts = $line.Split('|')
        if ($parts.Count -ge 3 -and $parts[0] -in @('site_group_reference','site_reference','assignment_reference','controlled_text_or_json_reference')) {
            $key = "$($parts[1])|$($parts[2])"
            $selfIdentity = $key -in @(
                'sites.site_groups|site_group_id',
                'sites.sites|site_id',
                'sites.site_jurisdiction_assignments|site_jurisdiction_assignment_id'
            )
            if (-not $selfIdentity) { [void]$observedReferenceKeys.Add($key) }
        }
    }
    $unclassifiedReferences = @($observedReferenceKeys | Where-Object { -not $allowedReferenceKeys.Contains($_) } | Sort-Object)
    Assert-Condition ($unclassifiedReferences.Count -eq 0) ("Unclassified live fixture dependencies: " + ($unclassifiedReferences -join ', '))

    $normalizedAnalyzer = (($analyzerOutput | ForEach-Object { $_.TrimEnd() }) -join "`n") + "`n"
    $analyzerHash = Get-Sha256Hex ([Text.Encoding]::UTF8.GetBytes($normalizedAnalyzer))
    $reportLines.Add('STATUS=PASS')
    $reportLines.Add('SITE_GROUP_FIXTURES=' + $expectedGroups.Count)
    $reportLines.Add('SITE_FIXTURES=' + $expectedSites.Count)
    $reportLines.Add('ASSIGNMENT_FIXTURES=' + $expectedAssignments.Count)
    $reportLines.Add('DEPENDENCY_INVENTORY_ROWS=' + $dependencyRows.Count)
    $reportLines.Add('DECLARED_FOREIGN_KEYS=' + $actualFkKeys.Count)
    $reportLines.Add('OBSERVED_REFERENCE_BOUNDARIES=' + $observedReferenceKeys.Count)
    $reportLines.Add('TRACKED_SOURCE_OCCURRENCES=' + $trackedOccurrenceCount)
    $reportLines.Add('MAPPING_ROWS=' + $mappingRows.Count)
    $reportLines.Add('ANALYZER_SHA256=' + $analyzerHash)
    $reportLines.Add('PITX_ACTIVATION=CONFIRMED_UNCHANGED')
    Write-Output 'WAVE0_SYNTHETIC_CARPARK_FIXTURE_VALIDATION=PASS'
}
catch {
    $failure = $_.Exception.Message
    $reportLines.Add('STATUS=FAIL')
    $reportLines.Add('DIAGNOSTIC=' + (($failure -replace '[\r\n]+',' ') -replace [regex]::Escape($suffix),'<run>'))
}
finally {
    $cleanupFailures = New-Object 'System.Collections.Generic.List[string]'
    try {
        if (-not $containerCreated) {
            $resolvedIdentity = Get-InvocationOwnedDockerIdentityIfPresent container $containerName $runId
            if ($resolvedIdentity) { $containerIdentity = $resolvedIdentity; $containerCreated = $true }
        }
        if (-not $volumeCreated) {
            $resolvedIdentity = Get-InvocationOwnedDockerIdentityIfPresent volume $volumeName $runId
            if ($resolvedIdentity) { $volumeIdentity = $resolvedIdentity; $volumeCreated = $true }
        }
        if (-not $networkCreated) {
            $resolvedIdentity = Get-InvocationOwnedDockerIdentityIfPresent network $networkName $runId
            if ($resolvedIdentity) { $networkIdentity = $resolvedIdentity; $networkCreated = $true }
        }
    } catch { $cleanupFailures.Add($_.Exception.Message) }
    try {
        if ($containerCreated) {
            Test-DockerResourceIdentity container $containerName $containerIdentity $runId
            [void](Invoke-NativeCommand docker @('rm','--force',$containerIdentity) 'Wave 0 container cleanup failed')
        }
    } catch { $cleanupFailures.Add($_.Exception.Message) }
    try {
        if ($volumeCreated) {
            Test-DockerResourceIdentity volume $volumeName $volumeIdentity $runId
            [void](Invoke-NativeCommand docker @('volume','rm',$volumeIdentity) 'Wave 0 volume cleanup failed')
        }
    } catch { $cleanupFailures.Add($_.Exception.Message) }
    try {
        if ($networkCreated) {
            Test-DockerResourceIdentity network $networkName $networkIdentity $runId
            [void](Invoke-NativeCommand docker @('network','rm',$networkIdentity) 'Wave 0 network cleanup failed')
        }
    } catch { $cleanupFailures.Add($_.Exception.Message) }
    if ($temporaryRoot -and (Test-Path -LiteralPath $temporaryRoot)) { Remove-Item -LiteralPath $temporaryRoot -Recurse }

    if ($cleanupFailures.Count -gt 0) {
        $cleanupMessage = 'Wave 0 cleanup failed: ' + ($cleanupFailures -join ' | ')
        if ($failure) { $failure += ' | ' + $cleanupMessage } else { $failure = $cleanupMessage }
        for ($index = 0; $index -lt $reportLines.Count; $index++) {
            if ($reportLines[$index] -eq 'STATUS=PASS') { $reportLines[$index] = 'STATUS=FAIL' }
        }
        $reportLines.Add('CLEANUP_STATUS=FAIL')
    } else {
        $reportLines.Add('CLEANUP_STATUS=PASS')
    }

    $reportFullPath = if ([IO.Path]::IsPathRooted($ReportPath)) { $ReportPath } else { Join-Path $RepositoryRoot $ReportPath }
    $reportDirectory = Split-Path -Parent $reportFullPath
    if (-not (Test-Path -LiteralPath $reportDirectory)) { [IO.Directory]::CreateDirectory($reportDirectory) | Out-Null }
    [IO.File]::WriteAllLines($reportFullPath, $reportLines, (New-Object Text.UTF8Encoding($false)))
    Write-Output "WAVE0_REPORT=$reportFullPath"
}

if ($failure) { throw $failure }
