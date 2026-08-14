[CmdletBinding()]
param(
    [string]$RepositoryRoot,
    [switch]$RunNegativeTests,
    [string[]]$ChangedPaths
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (-not $RepositoryRoot) {
    $RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
}

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

function Test-ReadOnlySql {
    param([string]$Path)
    $text = [IO.File]::ReadAllText($Path)
    Assert-True ($text -match '(?im)^\s*BEGIN\s+(?:TRANSACTION\s+)?READ\s+ONLY\s*;') "$Path must begin a read-only transaction."
    Assert-True ($text -notmatch '(?im)^\s*(INSERT|UPDATE|DELETE|MERGE|TRUNCATE|ALTER|DROP|CREATE|CALL|DO|VACUUM|REINDEX|CLUSTER|GRANT|REVOKE|COPY\s+.+\s+FROM)\b') "$Path contains a prohibited mutating SQL statement."
    Assert-True ($text -notmatch '(?im)\bSELECT\b[^;]*\bINTO\s+(?:TEMP|TEMPORARY|UNLOGGED|TABLE)\b') "$Path creates state through SELECT INTO."
}

function Test-ActivationText {
    param([string]$Text, [string]$Label)

    $forbiddenCaseInsensitive = @(
        ('PROPOSED' + '_NOT_ACTIVATED'),
        ('non' + '-activated'),
        ('not ' + 'activated'),
        ('proposed ' + 'activation'),
        ('future activation ' + 'proposal'),
        ('before a later PITX ' + 'activation'),
        ('unless separately ' + 'activated')
    )
    $catalogStatusPattern = '\b' + 'DRA' + 'FT\b'
    $targetToken = 'PIT' + 'X'
    $questionedActivationPattern = '(?i)' + $targetToken + '[^\r\n]{0,120}\b(pending|provisional|assumed|unverified|inactive|non-' + 'operational)\b'

    Assert-True (-not [regex]::IsMatch($Text, $catalogStatusPattern, [Text.RegularExpressions.RegexOptions]::CultureInvariant)) "$Label contains prohibited catalog-status wording."
    foreach ($phrase in $forbiddenCaseInsensitive) {
        Assert-True ($Text.IndexOf($phrase, [StringComparison]::OrdinalIgnoreCase) -lt 0) "$Label contains contradictory PITX activation wording: $phrase"
    }
    Assert-True (-not [regex]::IsMatch($Text, $questionedActivationPattern)) "$Label questions confirmed PITX activation."
}

function Test-Wave0ChangedPaths {
    param([string[]]$Paths)

    $protectedExactPaths = @(
        'docs/v1.3/reference-data/ExitPass_Synthetic_Carpark_Fixture_Reconciliation_and_Migration_Plan_v1.0.md',
        'docs/v1.3/reference-data/data/ExitPass_Synthetic_Carpark_Fixture_Dependent_Reference_Inventory_v1.0.csv',
        'docs/v1.3/reference-data/data/ExitPass_Synthetic_Carpark_Fixture_Tracked_Source_Occurrence_Inventory_v1.0.csv',
        'docs/v1.3/reference-data/data/ExitPass_Synthetic_Site_Fixture_Inventory_v1.0.csv',
        'docs/v1.3/reference-data/data/ExitPass_Synthetic_Site_Group_Fixture_Inventory_v1.0.csv',
        'docs/v1.3/reference-data/data/ExitPass_Synthetic_Site_Jurisdiction_Assignment_Inventory_v1.0.csv',
        'docs/v1.3/reference-data/data/ExitPass_Synthetic_to_Realistic_Identity_Reconciliation_v1.0.csv',
        'scripts/validation/Analyze-SyntheticCarparkFixtureDependencies.sql',
        'scripts/validation/Validate-SyntheticCarparkFixtureReconciliation.sql'
    )
    foreach ($pathValue in @($Paths)) {
        $path = $pathValue.Replace('\', '/')
        $restricted = $path.StartsWith('migrations/', [StringComparison]::OrdinalIgnoreCase) -or
            $path.StartsWith('objects/reference-data/', [StringComparison]::OrdinalIgnoreCase) -or
            $path.StartsWith('objects/uat/', [StringComparison]::OrdinalIgnoreCase) -or
            $path.StartsWith('scripts/uat/', [StringComparison]::OrdinalIgnoreCase) -or
            $path.StartsWith('build/generated/', [StringComparison]::OrdinalIgnoreCase) -or
            $path -match '(?i)(^|/)[^/]*seed[^/]*\.sql$' -or
            $path.Equals('reference-data/ExitPass_Reference_Data_v1.2.sql', [StringComparison]::OrdinalIgnoreCase) -or
            $path.IndexOf('hikcentral', [StringComparison]::OrdinalIgnoreCase) -ge 0 -or
            $path -in $protectedExactPaths
        Assert-True (-not $restricted) "Wave 0 cannot change seed, migration, fixture baseline, generated SQL, or HikCentral path: $path"
    }
}

function Test-PackageActivationLanguage {
    param([string]$Root)

    $relativePaths = @(
        'docs\v1.3\reference-data\ExitPass_Synthetic_Carpark_Fixture_Reconciliation_and_Migration_Plan_v1.0.md',
        'docs\v1.3\reference-data\data\ExitPass_Synthetic_Carpark_Fixture_Dependent_Reference_Inventory_v1.0.csv',
        'docs\v1.3\reference-data\data\ExitPass_Synthetic_Carpark_Fixture_Tracked_Source_Occurrence_Inventory_v1.0.csv',
        'docs\v1.3\reference-data\data\ExitPass_Synthetic_Site_Fixture_Inventory_v1.0.csv',
        'docs\v1.3\reference-data\data\ExitPass_Synthetic_Site_Group_Fixture_Inventory_v1.0.csv',
        'docs\v1.3\reference-data\data\ExitPass_Synthetic_Site_Jurisdiction_Assignment_Inventory_v1.0.csv',
        'docs\v1.3\reference-data\data\ExitPass_Synthetic_to_Realistic_Identity_Reconciliation_v1.0.csv',
        'scripts\validation\Analyze-SyntheticCarparkFixtureDependencies.sql',
        'scripts\validation\Test-SyntheticCarparkFixtureReconciliationPlan.ps1',
        'scripts\validation\Validate-SyntheticCarparkFixtureReconciliation.sql'
    )
    foreach ($relativePath in $relativePaths) {
        $path = Join-Path $Root $relativePath
        Assert-True (Test-Path -LiteralPath $path -PathType Leaf) "Missing reconciliation package file: $relativePath"
        $text = [IO.File]::ReadAllText($path)
        Test-ActivationText -Text $text -Label $relativePath
    }

    $plan = [IO.File]::ReadAllText((Join-Path $Root $relativePaths[0]))
    Assert-True ($plan.Contains('PITX Level 3 is activated')) 'The plan must affirm confirmed PITX Level 3 activation.'
    Assert-True ($plan.Contains('Senior Citizen free-parking privilege is confirmed and operational')) 'The plan must affirm confirmed PITX statutory coverage.'
    Assert-True ($plan.Contains('This documentation-only reconciliation task does not configure, activate, start, or contact any HikCentral target.')) 'The plan must express HikCentral handling as a task-scope limitation.'
}

function Test-PlanData {
    param(
        [object[]]$Groups,
        [object[]]$Sites,
        [object[]]$Assignments,
        [object[]]$Dependencies,
        [object[]]$Mappings,
        [object[]]$SourceOccurrences
    )

    $classifications = @('CONTROLLED_TEST_FIXTURE','SYNTHETIC_REPLACEMENT_CANDIDATE','SYNTHETIC_NO_REALISTIC_EQUIVALENT','HISTORICAL_IDENTITY','DUPLICATE_IDENTITY_CANDIDATE','UNRESOLVED_IDENTITY')
    $dispositions = @('KEEP_UNCHANGED','KEEP_FOR_TEST_SCOPE_ONLY','RETAIN_HISTORICAL_DISABLE_FUTURE_USE','MIGRATE_CONTROLLED_REFERENCES_THEN_RETAIN','MIGRATE_CONTROLLED_REFERENCES_THEN_RETIRE','DELETE_ONLY_IF_PROVEN_UNREFERENCED','SCHEMA_OR_GOVERNANCE_DECISION_REQUIRED','NO_ACTION_PENDING_EVIDENCE')
    $allFixtures = @($Groups) + @($Sites) + @($Assignments)

    Assert-True ($Groups.Count -eq 5) 'Expected four canonical Site Group fixtures plus the conditional overloaded 7700 fixture.'
    Assert-True ($Sites.Count -eq 93) 'Expected 92 canonical Site fixtures plus the conditional overloaded 7700 fixture.'
    Assert-True ($Assignments.Count -eq 90) 'Expected 90 synthetic jurisdiction assignments.'
    Assert-True (@($allFixtures | Group-Object fixture_id | Where-Object Count -ne 1).Count -eq 0) 'Every fixture identifier must occur exactly once across its inventory layer.'
    Assert-True (@($allFixtures | Where-Object { $_.identity_classification -notin $classifications }).Count -eq 0) 'Every fixture must have exactly one allowed identity classification.'
    Assert-True (@($allFixtures | Where-Object { $_.proposed_disposition -notin $dispositions }).Count -eq 0) 'Every fixture must have exactly one allowed proposed disposition.'

    $siteIds = @{}; foreach ($row in $Sites) { $siteIds[$row.fixture_id] = $true }
    Assert-True (@($Assignments | Where-Object { -not $siteIds.ContainsKey($_.site_id) }).Count -eq 0) 'Every assignment fixture must resolve to an inventoried Site.'

    Assert-True ($Mappings.Count -eq $allFixtures.Count) 'Every fixture must have exactly one reconciliation row.'
    Assert-True (@($Mappings | Group-Object fixture_id | Where-Object Count -ne 1).Count -eq 0) 'A fixture cannot map to multiple realistic identities.'
    Assert-True (@($Mappings | Where-Object {
        -not $_.mapping_decision -or -not $_.physical_identity_evidence -or
        -not $_.business_identity_evidence -or -not $_.jurisdiction_comparison -or
        -not $_.topology_comparison -or -not $_.confidence -or -not $_.approval_required
    }).Count -eq 0) 'Every mapping decision must contain evidence, confidence, and approval requirements.'
    $approvedTargets = @(
        '1c40a4b4-a607-5942-91b2-a7f8af80671a',
        'a6dbadf6-68b5-5bed-a7e0-a75faee70841',
        '2d1dcdf8-f563-537c-8542-0bde7cc9da97'
    )
    Assert-True (@($Mappings | Where-Object { $_.realistic_target_id -and $_.realistic_target_id -notin $approvedTargets }).Count -eq 0) 'A proposed realistic target does not exist in the approved target set.'
    Assert-True (@($Mappings | Where-Object { $_.operational_activation_change_in_scope -ne 'false' }).Count -eq 0) 'Reconciliation must not change operational activation for PITX or another realistic Site.'
    Assert-True (@($Mappings | Where-Object { $_.mapping_decision -match '^(APPROVED|MIGRATE|REPLACE|REPURPOSE)' }).Count -eq 0) 'Wave 0 cannot approve fixture identity migration or repurposing.'

    Assert-True (@($Dependencies | Where-Object { -not $_.reference_class }).Count -eq 0) 'Every dependency must be classified.'
    Assert-True (@($Dependencies | Where-Object { $_.historical -eq 'true' -and ($_.must_remain_immutable -ne 'true' -or $_.can_reassign_safely -eq 'true') }).Count -eq 0) 'Historical dependencies must remain immutable and non-reassignable.'
    $referencedIds = @{}; foreach ($row in $Dependencies) { if ([int64]$row.row_count -gt 0) { $referencedIds[$row.fixture_id] = $true } }
    Assert-True (@($allFixtures | Where-Object { $_.proposed_disposition -eq 'DELETE_ONLY_IF_PROVEN_UNREFERENCED' -and $referencedIds.ContainsKey($_.fixture_id) }).Count -eq 0) 'A referenced fixture cannot be marked directly deletable.'
    Assert-True (@($allFixtures | Where-Object { $_.proposed_disposition -eq 'DELETE_ONLY_IF_PROVEN_UNREFERENCED' }).Count -eq 0) 'Wave 0 grants no direct fixture deletion approval.'

    $testGroup = $Groups | Where-Object fixture_id -eq '77000000-0000-0000-0000-000000000001'
    $testSite = $Sites | Where-Object fixture_id -eq '77000000-0000-0000-0000-000000000002'
    Assert-True ($null -ne $testGroup -and $testGroup.proposed_disposition) 'Canonical Test Site Group requires an explicit disposition.'
    Assert-True ($null -ne $testSite -and $testSite.proposed_disposition) 'Canonical Test Site requires an explicit disposition.'
    Assert-True ($SourceOccurrences.Count -gt 0) 'Tracked source occurrence inventory must not be empty.'
    Assert-True (@($SourceOccurrences | Where-Object { -not $_.reference_type -or -not $_.repository -or -not $_.commit -or -not $_.path }).Count -eq 0) 'Every tracked source occurrence must be classified and commit-bound.'
}

$dataRoot = Join-Path $RepositoryRoot 'docs\v1.3\reference-data\data'
$groups = @(Import-Csv (Join-Path $dataRoot 'ExitPass_Synthetic_Site_Group_Fixture_Inventory_v1.0.csv'))
$sites = @(Import-Csv (Join-Path $dataRoot 'ExitPass_Synthetic_Site_Fixture_Inventory_v1.0.csv'))
$assignments = @(Import-Csv (Join-Path $dataRoot 'ExitPass_Synthetic_Site_Jurisdiction_Assignment_Inventory_v1.0.csv'))
$dependencies = @(Import-Csv (Join-Path $dataRoot 'ExitPass_Synthetic_Carpark_Fixture_Dependent_Reference_Inventory_v1.0.csv'))
$mappings = @(Import-Csv (Join-Path $dataRoot 'ExitPass_Synthetic_to_Realistic_Identity_Reconciliation_v1.0.csv'))
$sourceOccurrences = @(Import-Csv (Join-Path $dataRoot 'ExitPass_Synthetic_Carpark_Fixture_Tracked_Source_Occurrence_Inventory_v1.0.csv'))

Test-PackageActivationLanguage $RepositoryRoot
Test-PlanData $groups $sites $assignments $dependencies $mappings $sourceOccurrences
Test-ReadOnlySql (Join-Path $RepositoryRoot 'scripts\validation\Analyze-SyntheticCarparkFixtureDependencies.sql')
Test-ReadOnlySql (Join-Path $RepositoryRoot 'scripts\validation\Validate-SyntheticCarparkFixtureReconciliation.sql')
if ($ChangedPaths) { Test-Wave0ChangedPaths $ChangedPaths }

if ($RunNegativeTests) {
    $temporaryRoot = Join-Path ([IO.Path]::GetTempPath()) ("exitpass-fixture-plan-" + [guid]::NewGuid().ToString('N'))
    [IO.Directory]::CreateDirectory($temporaryRoot) | Out-Null
    try {
        $cases = @(
            @{ Name='omitted fixture'; Action={ param($g,$s,$a,$d,$m,$o) Test-PlanData @($g | Select-Object -Skip 1) $s $a $d $m $o } },
            @{ Name='multiple classifications'; Action={ param($g,$s,$a,$d,$m,$o) $g[0].identity_classification='CONTROLLED_TEST_FIXTURE;UNRESOLVED_IDENTITY'; Test-PlanData $g $s $a $d $m $o } },
            @{ Name='multiple dispositions'; Action={ param($g,$s,$a,$d,$m,$o) $g[0].proposed_disposition='KEEP_UNCHANGED;KEEP_FOR_TEST_SCOPE_ONLY'; Test-PlanData $g $s $a $d $m $o } },
            @{ Name='unclassified dependency'; Action={ param($g,$s,$a,$d,$m,$o) $d[0].reference_class=''; Test-PlanData $g $s $a $d $m $o } },
            @{ Name='missing mapping target'; Action={ param($g,$s,$a,$d,$m,$o) $m[0].realistic_target_id='00000000-0000-0000-0000-000000000099'; Test-PlanData $g $s $a $d $m $o } },
            @{ Name='multiple mapping targets'; Action={ param($g,$s,$a,$d,$m,$o) Test-PlanData $g $s $a $d @($m + $m[0]) $o } },
            @{ Name='historical row rewritable'; Action={ param($g,$s,$a,$d,$m,$o) $d[0].historical='true';$d[0].must_remain_immutable='false';$d[0].can_reassign_safely='true'; Test-PlanData $g $s $a $d $m $o } },
            @{ Name='referenced fixture directly deletable'; Action={ param($g,$s,$a,$d,$m,$o) $g[0].proposed_disposition='DELETE_ONLY_IF_PROVEN_UNREFERENCED';$d[0].fixture_id=$g[0].fixture_id;$d[0].row_count='1'; Test-PlanData $g $s $a $d $m $o } },
            @{ Name='Test Site without disposition'; Action={ param($g,$s,$a,$d,$m,$o) ($s | Where-Object fixture_id -eq '77000000-0000-0000-0000-000000000002').proposed_disposition=''; Test-PlanData $g $s $a $d $m $o } },
            @{ Name='new unclassified tracked source occurrence'; Action={ param($g,$s,$a,$d,$m,$o) $newOccurrence=[pscustomobject]@{repository='exitpassdb_v1.2';commit='test';path='scripts/validation/unclassified-fixture-reference.sql';reference_type='';matched_fixture_tokens='fixture-test-token';controls_runtime_behavior='false';later_migration_action='';current_action='';classification_basis=''}; Test-PlanData $g $s $a $d $m @($o + $newOccurrence) } },
            @{ Name='operational activation change introduced'; Action={ param($g,$s,$a,$d,$m,$o) ($m | Where-Object realistic_target_code -eq 'PITX-LEVEL-3').operational_activation_change_in_scope='true'; Test-PlanData $g $s $a $d $m $o } }
        )
        foreach ($case in $cases) {
            $g = @($groups | ForEach-Object { $_ | Select-Object * })
            $s = @($sites | ForEach-Object { $_ | Select-Object * })
            $a = @($assignments | ForEach-Object { $_ | Select-Object * })
            $d = @($dependencies | ForEach-Object { $_ | Select-Object * })
            $m = @($mappings | ForEach-Object { $_ | Select-Object * })
            $o = @($sourceOccurrences | ForEach-Object { $_ | Select-Object * })
            $failedAsExpected = $false
            try { & $case.Action $g $s $a $d $m $o } catch { $failedAsExpected = $true }
            Assert-True $failedAsExpected ("Negative test did not fail: " + $case.Name)
        }

        $writeSql = Join-Path $temporaryRoot 'write-regression.sql'
        [IO.File]::WriteAllText($writeSql, "BEGIN READ ONLY;`r`nINSERT INTO sites.sites DEFAULT VALUES;`r`n", (New-Object Text.UTF8Encoding($false)))
        $writeFailed = $false
        try { Test-ReadOnlySql $writeSql } catch { $writeFailed = $true }
        Assert-True $writeFailed 'Negative test did not reject a mutating SQL statement.'
        $activationFailed = $false
        try { Test-ActivationText -Text (('PIT' + 'X Level 3 is ') + 'pending') -Label 'negative activation fixture' } catch { $activationFailed = $true }
        Assert-True $activationFailed 'Negative test did not reject contradictory PITX activation language.'

        foreach ($restrictedPath in @('migrations/99999999999999_wave0_forbidden.sql','objects/reference-data/wave0-forbidden.seed.sql')) {
            $restrictedDiffFailed = $false
            try { Test-Wave0ChangedPaths @($restrictedPath) } catch { $restrictedDiffFailed = $true }
            Assert-True $restrictedDiffFailed "Negative test did not reject restricted path: $restrictedPath"
        }

        Write-Output 'NEGATIVE_TESTS_PASSED=13'
    }
    finally {
        if (Test-Path -LiteralPath $temporaryRoot) {
            Remove-Item -LiteralPath $temporaryRoot -Recurse
        }
    }
}

Write-Output ("SITE_GROUP_FIXTURES=" + $groups.Count)
Write-Output ("SITE_FIXTURES=" + $sites.Count)
Write-Output ("ASSIGNMENT_FIXTURES=" + $assignments.Count)
Write-Output ("DEPENDENCY_ROWS=" + $dependencies.Count)
Write-Output ("MAPPING_ROWS=" + $mappings.Count)
Write-Output ("SOURCE_OCCURRENCE_ROWS=" + $sourceOccurrences.Count)
Write-Output 'SYNTHETIC_CARPARK_FIXTURE_RECONCILIATION_PLAN_VALID'
