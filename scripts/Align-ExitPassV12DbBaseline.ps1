<#
.SYNOPSIS
Aligns the ExitPass v1.2 database repository baseline with the live development database.

.DESCRIPTION
This script treats exitpass_v12_dev as the source of truth, exports its schema using pg_dump
inside the Postgres Docker container, promotes the exported schema into the repository baseline,
rebuilds a clean comparison database, and verifies that Atlas diff is zero.

Source DB:
  exitpass_v12_dev

Clean rebuild DB:
  exitpass_v12_repo_clean

Expected Docker container:
  exitpass-postgres

Expected PostgreSQL host port:
  localhost:5433

Exit condition:
  Fails if Atlas reports any structural drift.
#>

param(
    [string]$RepoRoot = "D:\SourceCodes\ExitPass_DBv1.2",
    [string]$DockerContainer = "exitpass-postgres",
    [string]$DbUser = "exitpass",
    [string]$DbPassword = "change_me",
    [string]$LiveDb = "exitpass_v12_dev",
    [string]$CleanDb = "exitpass_v12_repo_clean",
    [string]$HostName = "localhost",
    [int]$HostPort = 5433,
    [string]$BaselineMigration = "migrations\20260512012142_baseline_v1_2.sql",
    [string]$CanonicalSnapshot = "snapshots\ExitPass_Full_Database_Creation_DDL_v1.2.sql",
    [string]$LiveSnapshot = "snapshots\ExitPass_Full_Database_Creation_DDL_v1.2.live_schema.sql",
    [string]$ReportDir = "drift-reports\atlas-v12-db-schema-alignment"
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Assert-CommandExists {
    param([string]$CommandName)

    if (-not (Get-Command $CommandName -ErrorAction SilentlyContinue)) {
        throw "Required command not found: $CommandName"
    }
}

function Invoke-Checked {
    param(
        [string]$Description,
        [scriptblock]$Command
    )

    Write-Step $Description
    & $Command

    if ($LASTEXITCODE -ne 0) {
        throw "Command failed: $Description"
    }
}

Write-Step "Validating required tools"
Assert-CommandExists "docker"
Assert-CommandExists "atlas"
Assert-CommandExists "git"

Write-Step "Moving to repository root"
Set-Location $RepoRoot

if (-not (Test-Path ".git")) {
    throw "This does not look like a Git repository: $RepoRoot"
}

if (-not (Test-Path "atlas.hcl")) {
    Write-Warning "atlas.hcl was not found. Continuing, but this should be the DB repo root."
}

Write-Step "Preparing folders"
New-Item -ItemType Directory -Force -Path ".\snapshots" | Out-Null
New-Item -ItemType Directory -Force -Path ".\$ReportDir" | Out-Null

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$containerDumpPath = "/tmp/ExitPass_Full_Database_Creation_DDL_v1.2.live_schema.sql"
$oldBaselineBackup = Join-Path $ReportDir "20260512012142_baseline_v1_2.old.$timestamp.sql"
$finalDiffPath = Join-Path $ReportDir "repo_clean_to_live_after_promoted_baseline.$timestamp.sql"
$finalCountPath = Join-Path $ReportDir "repo_clean_to_live_after_promoted_baseline.$timestamp.counts.txt"

Write-Step "Checking Docker container"
docker ps --filter "name=$DockerContainer" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

if ($LASTEXITCODE -ne 0) {
    throw "Unable to inspect Docker container: $DockerContainer"
}

Write-Step "Resetting actual PostgreSQL role password inside Docker"
docker exec $DockerContainer psql `
    -U $DbUser `
    -d postgres `
    -c "ALTER USER $DbUser WITH PASSWORD '$DbPassword';"

if ($LASTEXITCODE -ne 0) {
    throw "Unable to reset/check database user password."
}

Write-Step "Generating live schema dump inside Docker container"
docker exec $DockerContainer pg_dump `
    -U $DbUser `
    -d $LiveDb `
    --schema-only `
    --no-owner `
    --no-privileges `
    -f $containerDumpPath

if ($LASTEXITCODE -ne 0) {
    throw "pg_dump failed against live DB: $LiveDb"
}

Write-Step "Copying live schema dump to repository snapshots folder"
docker cp "${DockerContainer}:${containerDumpPath}" ".\$LiveSnapshot"

if ($LASTEXITCODE -ne 0) {
    throw "Failed to copy schema dump from Docker container."
}

Write-Step "Backing up current baseline migration"
if (Test-Path ".\$BaselineMigration") {
    Copy-Item ".\$BaselineMigration" ".\$oldBaselineBackup" -Force
} else {
    Write-Warning "Baseline migration does not exist yet: $BaselineMigration"
}

Write-Step "Promoting live schema dump into canonical snapshot and baseline migration"
Copy-Item ".\$LiveSnapshot" ".\$CanonicalSnapshot" -Force
Copy-Item ".\$LiveSnapshot" ".\$BaselineMigration" -Force

Write-Step "Dropping and recreating clean comparison database"
docker exec $DockerContainer psql `
    -U $DbUser `
    -d postgres `
    -c "DROP DATABASE IF EXISTS $CleanDb WITH (FORCE);"

if ($LASTEXITCODE -ne 0) {
    throw "Failed to drop clean comparison database: $CleanDb"
}

docker exec $DockerContainer psql `
    -U $DbUser `
    -d postgres `
    -c "CREATE DATABASE $CleanDb OWNER $DbUser;"

if ($LASTEXITCODE -ne 0) {
    throw "Failed to create clean comparison database: $CleanDb"
}

Write-Step "Copying promoted baseline migration into Docker"
docker cp ".\$BaselineMigration" "${DockerContainer}:/tmp/20260512012142_baseline_v1_2.sql"

if ($LASTEXITCODE -ne 0) {
    throw "Failed to copy promoted baseline migration into Docker."
}

Write-Step "Rebuilding clean comparison database from promoted baseline migration"
docker exec $DockerContainer psql `
    -U $DbUser `
    -d $CleanDb `
    -v ON_ERROR_STOP=1 `
    -f /tmp/20260512012142_baseline_v1_2.sql

if ($LASTEXITCODE -ne 0) {
    throw "Clean rebuild failed from promoted baseline migration."
}

$repoCleanUrl = "postgres://${DbUser}:${DbPassword}@${HostName}:${HostPort}/${CleanDb}?sslmode=disable"
$liveSourceUrl = "postgres://${DbUser}:${DbPassword}@${HostName}:${HostPort}/${LiveDb}?sslmode=disable"

Write-Step "Running Atlas diff from repo-clean DB to live DB"
atlas schema diff `
    --from $repoCleanUrl `
    --to $liveSourceUrl `
    > ".\$finalDiffPath"

if ($LASTEXITCODE -ne 0) {
    throw "Atlas schema diff failed."
}

Write-Step "Counting Atlas drift statements"
$diff = Get-Content ".\$finalDiffPath" -Raw

$counts = [PSCustomObject]@{
    AlterTables         = ([regex]::Matches($diff, '\bALTER TABLE\b')).Count
    CreateTables        = ([regex]::Matches($diff, '\bCREATE TABLE\b')).Count
    CreateIndexes       = ([regex]::Matches($diff, '\bCREATE INDEX\b')).Count
    CreateUniqueIndexes = ([regex]::Matches($diff, '\bCREATE UNIQUE INDEX\b')).Count
    AddConstraints      = ([regex]::Matches($diff, '\bADD CONSTRAINT\b')).Count
    DropStatements      = ([regex]::Matches($diff, '\bDROP\b')).Count
}

$counts | Format-List
$counts | Out-File ".\$finalCountPath"

$totalDrift =
    $counts.AlterTables +
    $counts.CreateTables +
    $counts.CreateIndexes +
    $counts.CreateUniqueIndexes +
    $counts.AddConstraints +
    $counts.DropStatements

if ($totalDrift -ne 0) {
    Write-Host ""
    Write-Host "Atlas drift is NOT zero. Review this file:" -ForegroundColor Red
    Write-Host $finalDiffPath -ForegroundColor Yellow
    throw "Database baseline alignment failed. Drift count: $totalDrift"
}

Write-Step "Atlas drift is zero"
Write-Host "Baseline migration, canonical snapshot, and live schema snapshot now match $LiveDb." -ForegroundColor Green
Write-Host ""
Write-Host "Updated files:" -ForegroundColor Cyan
Write-Host "  $BaselineMigration"
Write-Host "  $CanonicalSnapshot"
Write-Host "  $LiveSnapshot"
Write-Host ""
Write-Host "Evidence files:" -ForegroundColor Cyan
Write-Host "  $finalDiffPath"
Write-Host "  $finalCountPath"
Write-Host "  $oldBaselineBackup"
Write-Host ""
Write-Host "Next commands:" -ForegroundColor Cyan
Write-Host "  git status"
Write-Host "  git add migrations snapshots drift-reports"
Write-Host "  git commit -m `"Align ExitPass v1.2 database baseline with live schema`""
Write-Host "  git push"