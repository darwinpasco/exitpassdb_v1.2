[CmdletBinding()]
param(
    [string]$RepositoryRoot,
    [switch]$RunNegativeTests,
    [string]$DbHost,
    [int]$DbPort = 5432,
    [string]$DbUser = 'exitpass',
    [string]$DbPassword,
    [string]$AdminDatabase = 'postgres',
    [string]$ValidationDatabase = 'exitpass_real_carpark_boundary_validation',
    [string]$DockerContainer
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
}
$RepositoryRoot = (Resolve-Path -LiteralPath $RepositoryRoot).Path

$catalogCode = 'PROFESSIONAL_PARKING_REAL_CARPARK_V1'
$catalogHash = '63C20CD3ABA3E13D6F9FC022083507C0BC43A2AB9C751E9084DD19C59969359A'
$fixturePath = 'objects/test/sites.synthetic-metropolitan-site-groups-sites.fixture.sql'
$fixtureLeaf = 'sites.synthetic-metropolitan-site-groups-sites.fixture.sql'
$normalApplyPath = Join-Path $RepositoryRoot 'objects/exitpass-full-object-apply-order.txt'
$testApplyPath = Join-Path $RepositoryRoot 'objects/test/synthetic-carpark-fixture-apply-order.txt'
$generatedPath = Join-Path $RepositoryRoot 'build/generated/exitpass-full-object.generated.sql'
$referenceDataPath = Join-Path $RepositoryRoot 'objects/reference-data/exitpass.reference-data-v1.2.sql'
$catalogSeedPath = Join-Path $RepositoryRoot 'objects/reference-data/sites.realistic-carpark-catalog.seed.sql'
$migrationPath = Join-Path $RepositoryRoot 'migrations/20260911120000_management_platform_real_catalog_boundary.sql'
$stateValidationPath = Join-Path $RepositoryRoot 'scripts/validation/Validate-RealCarparkCatalogBoundaryState.sql'
$realisticValidationPath = Join-Path $RepositoryRoot 'scripts/validation/Validate-RealisticCarparkCatalog.sql'
$negativeTestCount = 0
$portabilityTestCount = 0

function Assert-Condition {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

function Get-NormalizedRepositoryRelativePath {
    param(
        [Parameter(Mandatory)][string]$Path,
        [string]$Root = $RepositoryRoot
    )

    $normalizedRoot = $Root.Replace('\', '/').TrimEnd([char[]]@('\', '/'))
    $normalizedPath = $Path.Replace('\', '/')
    if ($normalizedPath.Equals($normalizedRoot, [StringComparison]::OrdinalIgnoreCase)) { return '' }

    $rootPrefix = $normalizedRoot + '/'
    Assert-Condition ($normalizedPath.StartsWith($rootPrefix, [StringComparison]::OrdinalIgnoreCase)) "Path is outside the repository root: $Path"
    return $normalizedPath.Substring($rootPrefix.Length)
}

function Test-IsTestOnlyRepositoryPath {
    param([string]$Path, [string]$Root = $RepositoryRoot)
    $relativePath = Get-NormalizedRepositoryRelativePath -Path $Path -Root $Root
    return $relativePath.StartsWith('objects/test/', [StringComparison]::OrdinalIgnoreCase)
}

function Get-ApplyOrderEntries {
    param([string]$Text)
    return @($Text -split '\r?\n' |
        ForEach-Object { $_.Trim().Replace('\', '/') } |
        Where-Object { $_ -and -not $_.StartsWith('#') })
}

function Test-MntTopologyGuard {
    param([string]$Text, [string]$Label)

    $outerStart = $Text.IndexOf('\if :{?EXITPASS_INCLUDE_TEST_FIXTURES}', [StringComparison]::Ordinal)
    $innerStart = $Text.IndexOf('\if :EXITPASS_INCLUDE_TEST_FIXTURES', [StringComparison]::Ordinal)
    $firstEnd = if ($innerStart -ge 0) { $Text.IndexOf('\endif', $innerStart, [StringComparison]::Ordinal) } else { -1 }
    $secondEnd = if ($firstEnd -ge 0) { $Text.IndexOf('\endif', $firstEnd + 6, [StringComparison]::Ordinal) } else { -1 }
    Assert-Condition ($outerStart -ge 0 -and $innerStart -gt $outerStart -and $firstEnd -gt $innerStart -and $secondEnd -gt $firstEnd) "$Label does not contain the required explicit nested test-fixture guard."

    foreach ($token in @(
        '594afaf3-6f55-54be-933d-c6572f4e02ec',
        '110a07ad-773f-5018-b18a-d4d78e2ae6dd',
        'db5f423b-ed17-59d4-a5be-e7440aca5b21'
    )) {
        foreach ($match in [regex]::Matches($Text, [regex]::Escape($token), [Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
            Assert-Condition ($match.Index -gt $innerStart -and $match.Index -lt $firstEnd) "$Label exposes MNT topology token $token outside explicit test opt-in."
        }
        Assert-Condition ($Text.IndexOf($token, [StringComparison]::OrdinalIgnoreCase) -ge 0) "$Label no longer contains the preserved test-only MNT topology token $token."
    }
}

function Test-SourceBoundary {
    param(
        [string]$NormalApplyText,
        [string]$TestApplyText,
        [string]$GeneratedText,
        [string]$ReferenceDataText
    )

    $normalEntries = @(Get-ApplyOrderEntries $NormalApplyText)
    $testEntries = @(Get-ApplyOrderEntries $TestApplyText)
    Assert-Condition ($fixturePath -notin $normalEntries) 'Synthetic metropolitan fixture is reachable through the normal full-object apply order.'
    Assert-Condition (@($normalEntries | Where-Object { $_ -match '^objects/(test|uat)/' }).Count -eq 0) 'Normal full-object apply order includes a test/UAT object path.'
    Assert-Condition (@($normalEntries | Where-Object { $_ -eq 'objects/reference-data/sites.realistic-carpark-catalog.seed.sql' }).Count -eq 1) 'Normal apply order must contain the canonical realistic catalog seed exactly once.'
    Assert-Condition ($testEntries.Count -eq 2) 'Explicit synthetic fixture apply order must contain exactly two entries.'
    Assert-Condition ($testEntries[0] -eq 'objects/reference-data/exitpass.reference-data-v1.2.sql' -and $testEntries[1] -eq $fixturePath) 'Explicit fixture apply order changed or is not deterministic.'

    Assert-Condition ($GeneratedText.IndexOf("-- Source object: $fixturePath", [StringComparison]::OrdinalIgnoreCase) -lt 0) 'Synthetic fixture source is embedded in normal generated SQL.'
    foreach ($code in @('SAMPLE-METRO-MANILA','SAMPLE-METRO-CEBU','SAMPLE-METRO-DAVAO')) {
        Assert-Condition ($GeneratedText.IndexOf($code, [StringComparison]::OrdinalIgnoreCase) -lt 0) "Synthetic metropolitan code $code is embedded in normal generated SQL."
    }
    Assert-Condition ($ReferenceDataText.IndexOf($fixtureLeaf, [StringComparison]::OrdinalIgnoreCase) -lt 0) 'Synthetic metropolitan fixture is reachable from normal reference data without explicit fixture application.'
    Test-MntTopologyGuard -Text $ReferenceDataText -Label 'Reference data'
    Test-MntTopologyGuard -Text $GeneratedText -Label 'Generated normal SQL'
}

function Test-MigrationAndSeedSource {
    $migration = [IO.File]::ReadAllText($migrationPath)
    $seed = [IO.File]::ReadAllText($catalogSeedPath)
    Assert-Condition ($migration -match '(?m)^BEGIN;\s*$' -and $migration -match '(?m)^COMMIT;\s*$') 'Catalog-boundary migration must be transactional.'
    Assert-Condition (-not ($migration -match '(?im)^\s*(ALTER|DROP|TRUNCATE|DELETE|UPDATE)\b')) 'Catalog-boundary migration is no longer additive.'
    Assert-Condition ([regex]::Matches($migration, '(?im)^CREATE TABLE sites\.real_carpark_catalog_(site_groups|sites)\s*\(').Count -eq 2) 'Catalog-boundary migration must create only the two approved membership tables.'
    foreach ($text in @($migration, $seed)) {
        Assert-Condition ($text.Contains($catalogCode)) 'Catalog code is missing from migration or seed.'
        Assert-Condition ($text.Contains($catalogHash)) 'Approved workbook SHA-256 is missing from migration or seed.'
        Assert-Condition ($text -match 'count\(\*\).+39' -and $text -match 'count\(\*\).+46') 'Migration or seed no longer asserts 39/46 cardinality.'
    }
    Assert-Condition ($seed -match 'Site parent mismatch|parent or assignment relationship is inconsistent') 'Canonical seed no longer protects Site parent mappings.'
}

function Test-NormalConstructionReferences {
    foreach ($applyOrder in @(Get-ChildItem $RepositoryRoot -Recurse -File -Filter '*apply-order*.txt')) {
        $relativePath = Get-NormalizedRepositoryRelativePath $applyOrder.FullName
        if ($relativePath.Equals('objects/test/synthetic-carpark-fixture-apply-order.txt', [StringComparison]::OrdinalIgnoreCase)) { continue }
        $text = [IO.File]::ReadAllText($applyOrder.FullName)
        Assert-Condition ($text.IndexOf($fixtureLeaf, [StringComparison]::OrdinalIgnoreCase) -lt 0) "Synthetic fixture path is reachable from a non-test apply order: $relativePath"
    }

    $candidateFiles = New-Object 'System.Collections.Generic.List[IO.FileInfo]'
    foreach ($root in @('objects', 'scripts/build', 'scripts/uat', '.github/workflows')) {
        $fullRoot = Join-Path $RepositoryRoot $root
        if (-not (Test-Path -LiteralPath $fullRoot)) { continue }
        foreach ($file in @(Get-ChildItem $fullRoot -Recurse -File | Where-Object { $_.Extension -in @('.sql','.txt','.ps1','.yml','.yaml') })) {
            if (Test-IsTestOnlyRepositoryPath $file.FullName) { continue }
            $candidateFiles.Add($file)
        }
    }
    foreach ($file in $candidateFiles) {
        $relativePath = Get-NormalizedRepositoryRelativePath $file.FullName
        $text = [IO.File]::ReadAllText($file.FullName)
        Assert-Condition ($text.IndexOf($fixtureLeaf, [StringComparison]::OrdinalIgnoreCase) -lt 0) "Synthetic fixture path is reachable from normal construction source: $relativePath"
    }
}

function Test-GeneratedReproducibility {
    $temporaryOutput = 'build/generated/exitpass-full-object.boundary-validation.tmp.sql'
    $temporaryFullPath = Join-Path $RepositoryRoot $temporaryOutput
    try {
        & (Join-Path $RepositoryRoot 'scripts/build/Build-ExitPassFullObjectSql.ps1') -RepoRoot $RepositoryRoot -OutputPath $temporaryOutput
        $expectedHash = (Get-FileHash -LiteralPath $generatedPath -Algorithm SHA256).Hash
        $actualHash = (Get-FileHash -LiteralPath $temporaryFullPath -Algorithm SHA256).Hash
        Assert-Condition ($expectedHash -ceq $actualHash) "Committed generated SQL is not byte-stable with current object source. Expected $expectedHash, generated $actualHash."
    }
    finally {
        if (Test-Path -LiteralPath $temporaryFullPath) { Remove-Item -LiteralPath $temporaryFullPath }
    }
}

function Invoke-NativeCapture {
    param([string]$FilePath, [string[]]$Arguments, [string]$FailureMessage)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = @(& $FilePath @Arguments 2>&1 | ForEach-Object { $_.ToString() })
        $exitCode = $LASTEXITCODE
    }
    finally { $ErrorActionPreference = $oldPreference }
    if ($exitCode -ne 0) {
        $tail = @($output | Select-Object -Last 25) -join "`n"
        throw "$FailureMessage (exit $exitCode).`n$tail"
    }
    return $output
}

function Get-PsqlBaseArguments {
    param([string]$Database)
    if ($DockerContainer) { return @('exec', $DockerContainer, 'psql', '-X', '-q', '-A', '-t', '-v', 'ON_ERROR_STOP=1', '-U', $DbUser, '-d', $Database) }
    return @('-X', '-q', '-A', '-t', '-h', $DbHost, '-p', $DbPort.ToString(), '-U', $DbUser, '-d', $Database, '-v', 'ON_ERROR_STOP=1')
}

function Invoke-PsqlCommand {
    param([string]$Database, [string]$Sql)
    $args = @(Get-PsqlBaseArguments $Database) + @('-c', $Sql)
    $program = if ($DockerContainer) { 'docker' } else { 'psql' }
    return @(Invoke-NativeCapture $program $args "PostgreSQL command failed in $Database")
}

function Invoke-PsqlFile {
    param([string]$Database, [string]$Path, [hashtable]$Variables = @{})
    $psqlPath = $Path
    if ($DockerContainer) {
        $remoteName = '/tmp/real-carpark-boundary-' + ([IO.Path]::GetFileName($Path) -replace '[^A-Za-z0-9_.-]', '-')
        [void](Invoke-NativeCapture 'docker' @('cp', $Path, "$DockerContainer`:$remoteName") "Cannot copy $Path into validation container")
        $psqlPath = $remoteName
    }
    $args = @(Get-PsqlBaseArguments $Database)
    foreach ($key in @($Variables.Keys | Sort-Object)) { $args += @('-v', "$key=$($Variables[$key])") }
    $args += @('-f', $psqlPath)
    $program = if ($DockerContainer) { 'docker' } else { 'psql' }
    return @(Invoke-NativeCapture $program $args "PostgreSQL file failed in $Database`: $Path")
}

function New-ValidationDatabase {
    param([string]$Name, [string]$Template)
    Assert-Condition ($Name -match '^[a-z0-9_]+$' -and $Name.Length -le 63) "Unsafe validation database name: $Name"
    [void](Invoke-PsqlCommand $AdminDatabase "DROP DATABASE IF EXISTS $Name WITH (FORCE);")
    $create = if ($Template) { "CREATE DATABASE $Name TEMPLATE $Template;" } else { "CREATE DATABASE $Name;" }
    [void](Invoke-PsqlCommand $AdminDatabase $create)
}

function Remove-ValidationDatabase {
    param([string]$Name)
    if ($Name -and $Name -match '^[a-z0-9_]+$') { [void](Invoke-PsqlCommand $AdminDatabase "DROP DATABASE IF EXISTS $Name WITH (FORCE);") }
}

function Test-BoundaryState {
    param([string]$Database, [int]$ExpectedGroups, [int]$ExpectedSites, [bool]$ExpectFixture)
    $variables = @{
        expected_total_groups = $ExpectedGroups
        expected_total_sites = $ExpectedSites
        expect_synthetic_fixture = $(if ($ExpectFixture) { 'true' } else { 'false' })
    }
    [void](Invoke-PsqlFile $Database $stateValidationPath $variables)
}

function Test-ExpectedFailure {
    param([string]$Name, [scriptblock]$Action)
    $failed = $false
    try { & $Action } catch { $failed = $true }
    Assert-Condition $failed "Negative test did not fail: $Name"
    $script:negativeTestCount++
    Write-Host "Negative boundary test passed: $Name"
}

function Test-PortabilityExpectedFailure {
    param([string]$Name, [scriptblock]$Action)
    $failed = $false
    try { & $Action } catch { $failed = $true }
    Assert-Condition $failed "Portability test did not fail: $Name"
    $script:portabilityTestCount++
    Write-Host "Path portability test passed: $Name"
}

function Test-RepositoryPathPortability {
    $testCases = @(
        @{ Name = 'forward-slash explicit test apply order'; Root = '/repo'; Path = '/repo/objects/test/synthetic-carpark-fixture-apply-order.txt' },
        @{ Name = 'backslash explicit test apply order'; Root = 'C:\repo'; Path = 'C:\repo\objects\test\synthetic-carpark-fixture-apply-order.txt' }
    )
    foreach ($case in $testCases) {
        $relativePath = Get-NormalizedRepositoryRelativePath -Path $case.Path -Root $case.Root
        Assert-Condition ($relativePath -ceq 'objects/test/synthetic-carpark-fixture-apply-order.txt') "Repository-relative normalization failed: $($case.Name)"
        Assert-Condition (Test-IsTestOnlyRepositoryPath -Path $case.Path -Root $case.Root) "Explicit test apply order was classified as normal source: $($case.Name)"
        $script:portabilityTestCount++
        Write-Host "Path portability test passed: $($case.Name)"
    }

    Test-PortabilityExpectedFailure 'forward-slash normal source fixture reachability' {
        $path = Get-NormalizedRepositoryRelativePath -Path '/repo/objects/reference-data/normal.sql' -Root '/repo'
        Assert-Condition (-not $path.StartsWith('objects/test/', [StringComparison]::OrdinalIgnoreCase)) 'Normal source was classified as test-only.'
        Assert-Condition ('objects/test/sites.synthetic-metropolitan-site-groups-sites.fixture.sql'.IndexOf($fixtureLeaf, [StringComparison]::OrdinalIgnoreCase) -lt 0) "Synthetic fixture path is reachable from normal construction source: $path"
    }
    Test-PortabilityExpectedFailure 'backslash normal source fixture reachability' {
        $path = Get-NormalizedRepositoryRelativePath -Path 'C:\repo\objects\reference-data\normal.sql' -Root 'C:\repo'
        Assert-Condition (-not $path.StartsWith('objects/test/', [StringComparison]::OrdinalIgnoreCase)) 'Normal source was classified as test-only.'
        Assert-Condition ('objects\test\sites.synthetic-metropolitan-site-groups-sites.fixture.sql'.IndexOf($fixtureLeaf, [StringComparison]::OrdinalIgnoreCase) -lt 0) "Synthetic fixture path is reachable from normal construction source: $path"
    }
    Test-PortabilityExpectedFailure 'normal apply order fixture reachability after separator normalization' {
        Test-SourceBoundary ($normalApplyText + "`nobjects\test\sites.synthetic-metropolitan-site-groups-sites.fixture.sql") $testApplyText $generatedText $referenceDataText
    }
}

$normalApplyText = [IO.File]::ReadAllText($normalApplyPath)
$testApplyText = [IO.File]::ReadAllText($testApplyPath)
$generatedText = [IO.File]::ReadAllText($generatedPath)
$referenceDataText = [IO.File]::ReadAllText($referenceDataPath)

Test-RepositoryPathPortability
Assert-Condition ($portabilityTestCount -eq 5) "Expected 5 path portability tests, observed $portabilityTestCount."
Test-SourceBoundary $normalApplyText $testApplyText $generatedText $referenceDataText
Test-NormalConstructionReferences
Test-MigrationAndSeedSource
Test-GeneratedReproducibility

# Preserve the useful Wave 0 inventory, immutable-history, cleanup-safety, source-occurrence,
# and PITX consistency checks. Changed-path prohibition is intentionally not passed.
& (Join-Path $RepositoryRoot 'scripts/validation/Test-SyntheticCarparkFixtureReconciliationPlan.ps1') -RepositoryRoot $RepositoryRoot

if ($RunNegativeTests) {
    Test-ExpectedFailure 'synthetic fixture added to normal apply order' {
        Test-SourceBoundary ($normalApplyText + "`n$fixturePath") $testApplyText $generatedText $referenceDataText
    }
    Test-ExpectedFailure 'synthetic fixture SQL embedded in normal generated SQL' {
        Test-SourceBoundary $normalApplyText $testApplyText ($generatedText + "`nSAMPLE-METRO-MANILA") $referenceDataText
    }
    Test-ExpectedFailure 'fixture path reachable from normal reference data' {
        Test-SourceBoundary $normalApplyText $testApplyText $generatedText ($referenceDataText + "`n\ir ../test/sites.synthetic-metropolitan-site-groups-sites.fixture.sql")
    }
}

Assert-Condition ($DockerContainer -or $DbHost) 'Specify either -DbHost for psql mode or -DockerContainer for Docker exec mode.'
if (-not $DockerContainer) { [void](Get-Command psql -ErrorAction Stop) }

$previousPassword = $env:PGPASSWORD
if (-not $DockerContainer -and -not [string]::IsNullOrWhiteSpace($DbPassword)) { $env:PGPASSWORD = $DbPassword }
$createdDatabases = New-Object 'System.Collections.Generic.List[string]'
$normalDatabase = $ValidationDatabase.ToLowerInvariant()
$migrationA = ($ValidationDatabase + '_migration_a').ToLowerInvariant()
$migrationB = ($ValidationDatabase + '_migration_b').ToLowerInvariant()

try {
    New-ValidationDatabase $normalDatabase $null
    $createdDatabases.Add($normalDatabase)
    [void](Invoke-PsqlFile $normalDatabase $generatedPath)
    [void](Invoke-PsqlFile $normalDatabase $realisticValidationPath)
    [void](Invoke-PsqlFile $normalDatabase $catalogSeedPath)
    [void](Invoke-PsqlFile $normalDatabase $catalogSeedPath)
    Test-BoundaryState $normalDatabase 39 46 $false

    foreach ($migrationDatabase in @($migrationA, $migrationB)) {
        New-ValidationDatabase $migrationDatabase $normalDatabase
        $createdDatabases.Add($migrationDatabase)
        [void](Invoke-PsqlCommand $migrationDatabase 'DROP TABLE sites.real_carpark_catalog_sites; DROP TABLE sites.real_carpark_catalog_site_groups;')
        [void](Invoke-PsqlFile $migrationDatabase $migrationPath)
        [void](Invoke-PsqlFile $migrationDatabase $catalogSeedPath)
        [void](Invoke-PsqlFile $migrationDatabase $catalogSeedPath)
        Test-BoundaryState $migrationDatabase 39 46 $false
    }

    $digestSql = "SELECT encode(digest(string_agg(v, E'\n' ORDER BY v), 'sha256'),'hex') FROM (SELECT concat_ws('|',c.site_group_id,c.catalog_code,c.source_reference,c.source_sha256) v FROM sites.real_carpark_catalog_site_groups c UNION ALL SELECT concat_ws('|',c.site_id,c.site_group_id,c.catalog_code,c.source_reference,c.source_sha256) FROM sites.real_carpark_catalog_sites c) q;"
    $digestA = (@(Invoke-PsqlCommand $migrationA $digestSql) | Where-Object { $_.Trim() } | Select-Object -Last 1).Trim()
    $digestB = (@(Invoke-PsqlCommand $migrationB $digestSql) | Where-Object { $_.Trim() } | Select-Object -Last 1).Trim()
    Assert-Condition ($digestA -and $digestA -ceq $digestB) 'Migration output is not repeatable across equivalent database states.'

    foreach ($entry in @(Get-ApplyOrderEntries $testApplyText)) {
        [void](Invoke-PsqlFile $normalDatabase (Join-Path $RepositoryRoot $entry) @{ EXITPASS_INCLUDE_TEST_FIXTURES = 'true' })
    }
    foreach ($entry in @(Get-ApplyOrderEntries $testApplyText)) {
        [void](Invoke-PsqlFile $normalDatabase (Join-Path $RepositoryRoot $entry) @{ EXITPASS_INCLUDE_TEST_FIXTURES = 'true' })
    }
    Test-BoundaryState $normalDatabase 43 138 $true

    if ($RunNegativeTests) {
        $databaseCases = @(
            @{ Name = 'canonical group count is not 39'; Sql = "DELETE FROM sites.real_carpark_catalog_site_groups WHERE site_group_id='d54e01eb-b802-571e-9a47-ab328181a52f';" },
            @{ Name = 'canonical site count is not 46'; Sql = "DELETE FROM sites.real_carpark_catalog_sites WHERE site_id='2d1dcdf8-f563-537c-8542-0bde7cc9da97';" },
            @{ Name = 'synthetic UUID enters canonical group membership'; Sql = "INSERT INTO sites.real_carpark_catalog_site_groups(site_group_id,catalog_code,source_reference,source_sha256) VALUES('594afaf3-6f55-54be-933d-c6572f4e02ec','$catalogCode','D:\Docs\Carparks.xlsx','$catalogHash');" },
            @{ Name = 'real Site receives wrong Site Group parent'; Sql = "UPDATE sites.real_carpark_catalog_sites SET site_group_id=(SELECT site_group_id FROM sites.site_groups WHERE site_group_code='BRIDGETOWNE') WHERE site_id='2d1dcdf8-f563-537c-8542-0bde7cc9da97';" },
            @{ Name = 'explicit fixture changes canonical membership'; Sql = "INSERT INTO sites.real_carpark_catalog_sites(site_id,site_group_id,catalog_code,source_reference,source_sha256) VALUES('110a07ad-773f-5018-b18a-d4d78e2ae6dd','594afaf3-6f55-54be-933d-c6572f4e02ec','$catalogCode','D:\Docs\Carparks.xlsx','$catalogHash');" }
        )
        $caseIndex = 0
        foreach ($case in $databaseCases) {
            $caseIndex++
            $caseDatabase = ($ValidationDatabase + '_negative_' + $caseIndex).ToLowerInvariant()
            try {
                New-ValidationDatabase $caseDatabase $normalDatabase
                $createdDatabases.Add($caseDatabase)
                [void](Invoke-PsqlCommand $caseDatabase $case.Sql)
                Test-ExpectedFailure $case.Name { Test-BoundaryState $caseDatabase 43 138 $true }
            }
            finally {
                Remove-ValidationDatabase $caseDatabase
                [void]$createdDatabases.Remove($caseDatabase)
            }
        }
    }

    Assert-Condition (-not $RunNegativeTests -or $negativeTestCount -eq 8) "Expected 8 negative tests, observed $negativeTestCount."
    Write-Output 'REAL_CARPARK_CATALOG_BOUNDARY_VALIDATION=PASS'
    Write-Output 'NORMAL_TOPOLOGY=39_SITE_GROUPS/46_SITES'
    Write-Output 'EXPLICIT_TEST_FIXTURE_TOPOLOGY=43_SITE_GROUPS/138_SITES'
    Write-Output 'CANONICAL_MEMBERSHIP_WITH_FIXTURE=39_SITE_GROUPS/46_SITES'
    Write-Output "CATALOG_CODE=$catalogCode"
    Write-Output "NEGATIVE_TESTS=$negativeTestCount"
    Write-Output "PATH_PORTABILITY_TESTS=$portabilityTestCount"
    Write-Output "MIGRATION_REPEATABILITY_SHA256=$digestA"
}
finally {
    for ($index = $createdDatabases.Count - 1; $index -ge 0; $index--) {
        try { Remove-ValidationDatabase $createdDatabases[$index] } catch { Write-Warning $_.Exception.Message }
    }
    $env:PGPASSWORD = $previousPassword
}
