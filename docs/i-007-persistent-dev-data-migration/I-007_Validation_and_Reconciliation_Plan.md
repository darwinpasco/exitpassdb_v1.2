# I-007 Validation and Reconciliation Plan

## Source-Unchanged Proof

Future execution must prove the source database did not change during assessment/extraction with read-only row-count, size, and semantic-hash manifests. I-007 used read-only transactions only.

## Row Count Manifest

For each source and target table capture table name, row count, primary-key count, duplicate primary-key count, nullable required-key count, extract timestamp, and migration batch ID.

## Key and FK Validation

Validate primary-key uniqueness, natural-key uniqueness, all foreign keys, orphan absence, crosswalk closure, and that no target row without migration source exists unless created by canonical seed.

## Controlled-Code Validation

Validate every status/type/channel/code column against canonical enum or controlled-code tables. Unknown values fail the table stage.

## Monetary Reconciliation

For payment, tariff, discount, and fiscal tables, compare row counts, amount sums by currency, counts by status, payment provider/channel, confirmation-to-fiscal linkage, and applied statutory payable-basis totals where applicable.

## Timestamp Preservation

For every migrated table with timestamps, compare min/max created timestamps, min/max business/update timestamps, and null timestamp counts where target requires non-null.

## Site, Site Group, and Jurisdiction Validation

Required checks: every migrated Site has one Site Group; every migrated Site has deterministic `local_government_unit_id` or is blocked; Site Group is not legal ordinance authority; Site Group LGU scope derives through Sites; NCR LGUs have no province assignment; synthetic sample Sites remain disabled; no real Site collides with I-006 sample Site codes.

## Statutory Coverage Validation

Required checks: LGU policy inheritance works; no `NO_LOCAL_RULE_FOUND` row is covered; no `PROPOSED` row is covered; no research-derived row has `auto_application_allowed=true`; Paranaque Senior Citizen and PWD rows remain separate; Paranaque Senior Citizen is not downgraded due to unavailable online source text/number; stale decisions with missing frozen policy authority are archived or remediated before migration.

## Drift Validation

Future execution should run repository validation scripts against the canonical target:

```powershell
pwsh scripts/validation/Invoke-DbObjectSourceCiCheck.ps1 -SkipDbApply
pwsh scripts/validation/Invoke-DbObjectSourceCiCheck.ps1 -RunDbApply
```

Use the exact repository-supported command form in the future execution environment.

## Application Smoke Validation

Minimum smoke set: Central PMS startup, WebPay pending lifecycle rediscovery read path, Operator Console statutory review read path, Management Platform statutory policy coverage read API, APT statutory availability/read path when available, non-statutory payment smoke against a disposable/development target only, and POS/fiscal reference readback where retained.

## Backup Validation

Validate full dump checksum, schema dump checksum, `pg_restore --list`, restore rehearsal, restored row-count parity, and backup access controls.
