# I-007 Persistent Development Database Current-State Assessment

## Scope

This document records a read-only assessment of the stale persistent development database `exitpass_v12_dev` for a future migration, archival, rollback, and cutover task. It is design-only. It does not authorize migration execution, database rename, restore, drop, overwrite, truncate, schema change, row update, or application cutover.

## Repository Baseline

- Repository: `D:\SourceCodes\exitpassdb_v1.2`
- Assessment worktree: `D:\SourceCodes\exitpassdb_v1.2-I-PersistentDevDataMigration`
- Branch: `docs/persistent-development-data-migration-and-cutover`
- Base branch: `origin/develop`
- HEAD at assessment start: `c60cb4bc02d533e29769eb319ac23a5a1de0db7b`
- `origin/develop` at assessment start: `c60cb4bc02d533e29769eb319ac23a5a1de0db7b`
- Generated DDL authority: `build/generated/exitpass-full-object.generated.sql`
- Generated DDL SHA-256: `394C29A4C457CBA6112ED224A4B0F11E313E4AC44DA1FD03CE26F2BF050CAB3A`
- Retired repository `D:\SourceCodes\ExitPass_DBv1.2` was not used.

## Read-Only Safeguard

All persistent database inspection used PostgreSQL read-only safeguards:

- `SET default_transaction_read_only=on`
- `BEGIN READ ONLY`
- inspection queries were `SELECT` only

No role creation was attempted. No persistent database write was executed.

## PostgreSQL Environment

- Container: `exitpass-postgres`
- Image: `postgres:16-alpine`
- Host port: `5433 -> 5432/tcp`
- Database: `exitpass_v12_dev`
- PostgreSQL version: `PostgreSQL 16.14 on x86_64-pc-linux-musl`
- Owner: `exitpass`
- Size at assessment: `53 MB`
- Connection count at assessment query: `1`

## Schema Summary

| Schema | Tables | Views | Materialized views | Sequences | Indexes | Relation size |
|---|---:|---:|---:|---:|---:|---:|
| audit | 4 | 0 | 0 | 0 | 31 | 4272 kB |
| config | 5 | 0 | 0 | 0 | 18 | 280 kB |
| core | 17 | 0 | 0 | 0 | 80 | 10232 kB |
| coupons | 4 | 0 | 0 | 0 | 22 | 336 kB |
| discounts | 7 | 0 | 0 | 0 | 65 | 2088 kB |
| events | 5 | 0 | 0 | 0 | 37 | 6968 kB |
| gates | 4 | 0 | 0 | 0 | 33 | 2912 kB |
| identity | 6 | 0 | 0 | 0 | 27 | 2216 kB |
| integration | 6 | 0 | 0 | 0 | 35 | 1208 kB |
| merchants | 4 | 0 | 0 | 0 | 19 | 240 kB |
| operations | 5 | 0 | 0 | 0 | 30 | 2664 kB |
| operator_console | 5 | 0 | 0 | 0 | 17 | 456 kB |
| payments | 6 | 0 | 0 | 0 | 40 | 528 kB |
| reconciliation | 9 | 0 | 0 | 0 | 60 | 536 kB |
| sessions | 6 | 0 | 0 | 0 | 49 | 616 kB |
| sites | 4 | 0 | 0 | 0 | 18 | 4520 kB |

Function/procedure counts by schema: `core=7`, `coupons=3`, `discounts=3`, `events=1`, `gates=1`, `operations=1`, `public=36`, `reconciliation=2`.

Constraint counts: check `291`, foreign key `579`, primary key `97`, unique `43`.

## Data Summary

The database contains meaningful development-operational data and must not be discarded without archive and explicit decision:

- parking sessions: `3153`
- tariff snapshots: `3788`
- payment attempts: `2577`
- payment confirmations: `1695`
- exit authorizations: `1672`
- fiscal issuance references: `16`
- statutory validations: `485`
- statutory decision commands: `26`
- statutory payable-basis applications: `420`
- Operator Console statutory reviews: `23`
- gate authorization consumptions: `1657`
- site groups: `1787`
- sites: `1787`
- lanes: `1763`
- device assignments: `1761`
- service identities: `1776`
- users: `700`
- domain/outbox events: `5629` each
- audit events: `6671`

Safe timestamp ranges observed for key tables:

| Table | Rows | Earliest created | Latest created | Latest business/update timestamp |
|---|---:|---|---|---|
| core.parking_sessions | 3153 | 2026-06-09 02:10:28Z | 2026-07-31 10:35:59Z | 2026-07-31 10:35:59Z |
| core.payment_attempts | 2577 | 2026-06-20 05:31:52Z | 2026-07-31 09:18:53Z | 2026-07-31 09:18:53Z |
| core.payment_confirmations | 1695 | 2026-06-20 05:31:52Z | 2026-07-31 09:10:20Z | 2026-07-31 09:10:20Z |
| core.tariff_snapshots | 3788 | 2026-06-18 05:42:59Z | 2026-07-31 10:35:59Z | 2026-07-31 10:35:59Z |
| discounts.statutory_discount_validations | 485 | 2026-06-23 00:14:21Z | 2026-07-31 09:18:53Z | 2026-07-31 09:18:53Z |
| discounts.statutory_discount_decision_commands | 26 | 2026-07-24 08:29:34Z | 2026-07-25 07:16:21Z | 2026-07-25 07:16:21Z |
| operator_console.statutory_discount_service_channel_reviews | 23 | 2026-07-24 08:29:34Z | 2026-07-25 06:39:38Z | 2026-07-25 06:39:38Z |
| gates.gate_authorization_consumptions | 1657 | 2026-06-23 00:21:43Z | 2026-07-31 09:10:06Z | 2026-07-31 09:10:06Z |
| audit.audit_events | 6671 | 2026-06-11 02:25:15Z | 2026-08-03 00:57:04Z | 2026-08-03 00:57:04Z |

No raw customer, vehicle, payment, identity, credential, statutory ID, or protected evidence values are recorded in this assessment.

## Canonical Schema Comparison

The stale database is missing the I-006 canonical jurisdiction and statutory coverage model:

- `sites.philippine_regions`: absent
- `sites.philippine_provinces`: absent
- `sites.jurisdictions`: absent
- `sites.metropolitan_areas`: absent
- `sites.metropolitan_area_jurisdictions`: absent
- `sites.site_jurisdiction_assignments`: absent
- `sites.site_group_lgu_scopes`: absent
- `discounts.statutory_discount_policy_registry_lgu_scopes`: absent
- `discounts.statutory_parking_lgu_policy_coverage`: absent
- `discounts.statutory_parking_site_policy_coverage`: absent

Generated-DDL table comparison found `91` canonical tables versus `97` tables in the stale database. Missing canonical tables include I-006 geography, policy-version, decision-policy-authority, policy-import-review, and newer gate command tables. Extra stale tables include fiscal retry/backfill workflow tables, terminal cash command tables, provider routing policy tables, production policy import review tables, and session projection tables. This confirms that direct in-place patching is high risk.

## Sensitive Data Categories

The stale database likely includes internal operational, financial, authentication/authorization, personal-data, and possibly sensitive-personal statutory workflow metadata. The assessment intentionally records only counts, categories, date ranges, schema facts, and safe identifiers.

## Assessment Verdict

`exitpass_v12_dev` contains meaningful operational development data on a pre-canonical schema. It must remain preserved. The safest future execution path is a side-by-side canonical target with transformed selective migration and archive retention of the original database, not direct in-place alteration.
