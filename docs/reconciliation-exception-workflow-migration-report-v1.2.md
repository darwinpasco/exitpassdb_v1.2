# Reconciliation Exception Workflow Migration Report v1.2

Date: 2026-05-24  
Branch: `feat/apply-reconciliation-exception-workflow-schema`  
Database: `exitpass_v12_dev` on `localhost:5433`

## Summary

Applied the reconciliation-owned exception workflow schema to the live dev database. The migration adds maker-checker workflow tables for exception notes, resolution requests, approval decisions, and status history.

No application code was changed. No payment, provider, exit authorization, gate consumption, audit history, domain event history, outbox history, settlement, or payout data was mutated.

## Migration Files

- `migrations/20260524173500_reconciliation_exception_workflow_v1.2.sql`
- `migrations/20260524173500_reconciliation_exception_workflow_v1.2_rollback.sql`

Supporting proposal files remain:

- `docs/reconciliation-exception-workflow-schema-proposal-v1.2.md`
- `proposals/ExitPass_Reconciliation_Exception_Workflow_Proposal_v1.2.sql`
- `proposals/ExitPass_Reconciliation_Exception_Workflow_Proposal_v1.2_rollback.sql`

Schema snapshots regenerated from live DB:

- `snapshots/ExitPass_Full_Database_Creation_DDL_v1.2.sql`
- `snapshots/ExitPass_Full_Database_Creation_DDL_v1.2.live_schema.sql`

Baseline refreshed from live schema:

- `migrations/20260512012142_baseline_v1_2.sql`

Migration checksum refreshed:

- `migrations/atlas.sum`

## Live Schema Inspected First

Catalog inspection covered:

- `reconciliation.reconciliation_runs`
- `reconciliation.reconciliation_items`
- `reconciliation.reconciliation_exceptions`
- `audit.audit_events`
- `audit.audit_trail_entries`
- `events.domain_events`
- `events.outbox_events`
- `identity.users`
- `identity.roles`
- `identity.permissions`
- `identity.user_roles`
- `identity.role_permissions`
- `identity.service_identities`
- reconciliation, audit, events, and identity enum values
- primary keys, foreign keys, check constraints, indexes, defaults, and naming conventions

The inspection confirmed no live enum-name collisions for the workflow enums.

## Objects Created

Enums:

- `reconciliation.reconciliation_exception_note_type_enum`
- `reconciliation.reconciliation_resolution_action_enum`
- `reconciliation.reconciliation_resolution_request_status_enum`
- `reconciliation.reconciliation_resolution_approval_decision_enum`
- `reconciliation.reconciliation_financial_impact_enum`

Tables:

- `reconciliation.reconciliation_exception_notes`
- `reconciliation.reconciliation_exception_resolution_requests`
- `reconciliation.reconciliation_exception_resolution_approvals`
- `reconciliation.reconciliation_exception_status_history`

Each table includes primary keys, foreign keys to existing reconciliation/audit/identity tables, correlation fields, timestamps, row version checks, and supporting indexes.

## Apply Notes

The first migration attempt failed before commit because PostgreSQL truncated two long check constraint names on `reconciliation_exception_resolution_approvals` to the same 63-byte identifier. The transaction aborted and left no proposed objects behind.

The migration was hardened by shortening constraint names, then reapplied successfully:

```text
BEGIN
DO
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE INDEX ...
COMMIT
```

Two long index names were truncated by PostgreSQL but remained unique:

- `ux_reconciliation_exception_resolution_requests__active_excepti`
- `ix_reconciliation_exception_resolution_approvals__correlation_i`

## Validation Queries Run

Validated columns/defaults:

```sql
select table_schema, table_name, column_name, data_type, udt_name, is_nullable, column_default
from information_schema.columns
where table_schema = 'reconciliation'
  and table_name in (
    'reconciliation_exception_notes',
    'reconciliation_exception_resolution_requests',
    'reconciliation_exception_resolution_approvals',
    'reconciliation_exception_status_history'
  )
order by table_name, ordinal_position;
```

Validated enum values:

```sql
select n.nspname as schema_name, t.typname as enum_name, e.enumlabel as enum_value, e.enumsortorder
from pg_type t
join pg_enum e on e.enumtypid = t.oid
join pg_namespace n on n.oid = t.typnamespace
where n.nspname = 'reconciliation'
  and t.typname in (
    'reconciliation_exception_note_type_enum',
    'reconciliation_resolution_action_enum',
    'reconciliation_resolution_request_status_enum',
    'reconciliation_resolution_approval_decision_enum',
    'reconciliation_financial_impact_enum'
  )
order by t.typname, e.enumsortorder;
```

Validated constraints:

```sql
select conrelid::regclass as table_name, conname, contype, pg_get_constraintdef(oid) as definition
from pg_constraint
where connamespace = 'reconciliation'::regnamespace
  and conrelid::regclass::text in (
    'reconciliation.reconciliation_exception_notes',
    'reconciliation.reconciliation_exception_resolution_requests',
    'reconciliation.reconciliation_exception_resolution_approvals',
    'reconciliation.reconciliation_exception_status_history'
  )
order by conrelid::regclass::text, contype, conname;
```

Validated indexes:

```sql
select schemaname, tablename, indexname, indexdef
from pg_indexes
where schemaname = 'reconciliation'
  and tablename in (
    'reconciliation_exception_notes',
    'reconciliation_exception_resolution_requests',
    'reconciliation_exception_resolution_approvals',
    'reconciliation_exception_status_history'
  )
order by tablename, indexname;
```

## Row-Count Preservation

Pre-migration:

| Table | Count |
| --- | ---: |
| `reconciliation.reconciliation_runs` | 1 |
| `reconciliation.reconciliation_items` | 1 |
| `reconciliation.reconciliation_exceptions` | 0 |

Post-migration:

| Table | Count |
| --- | ---: |
| `reconciliation.reconciliation_runs` | 1 |
| `reconciliation.reconciliation_items` | 1 |
| `reconciliation.reconciliation_exceptions` | 0 |

New workflow tables are empty after migration:

| Table | Count |
| --- | ---: |
| `reconciliation.reconciliation_exception_notes` | 0 |
| `reconciliation.reconciliation_exception_resolution_requests` | 0 |
| `reconciliation.reconciliation_exception_resolution_approvals` | 0 |
| `reconciliation.reconciliation_exception_status_history` | 0 |

## Existing Run Readback

The existing persisted run remains readable:

| Run code | Status | Items | Matched | Exceptions | Source |
| --- | --- | ---: | ---: | ---: | --- |
| `PMWPR-20260524225728-411c05e6` | `COMPLETED` | 1 | 1 | 0 | `PAYMONGO;TICKET=WEBPAY-20260524-FRESH-009` |

Run id:

```text
411c05e6-c7a0-4a6b-a849-ea0d3dc9dcf2
```

## Static Checks

No out-of-scope provider references were found in the new migration/proposal/report files.

No settlement or payout tables were introduced. The only settlement/payout references are scope-boundary text in documentation, not `CREATE TABLE` statements.

The QRPH/PHP PAYMONGO-only assumption remains unchanged and documented.

## Rollback Status

Rollback draft exists:

- `migrations/20260524173500_reconciliation_exception_workflow_v1.2_rollback.sql`

Rollback was not executed against live dev. It should only be tested on a disposable database copy unless explicitly approved for live rollback.
