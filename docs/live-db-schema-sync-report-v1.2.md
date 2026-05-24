# ExitPass v1.2 Live DB Schema Sync Report

Date: 2026-05-24

Branch: `chore/live-db-reconciliation-readiness-sync`

Source database:

- Host: `localhost`
- Port: `5433`
- Database: `exitpass_v12_dev`
- User: `exitpass`

Target repository: `D:\SourceCodes\ExitPass_DBv1.2`

## Scope

The live PostgreSQL database was treated as the source of truth. The repository schema-only artifacts were synchronized from a live `pg_dump --schema-only` extraction. No live business data was mutated and no runtime ticket data was included in the baseline DDL.

The repository convention stores the full DDL in `snapshots/ExitPass_Full_Database_Creation_DDL_v1.2.sql`; the live extraction copy is kept in `snapshots/ExitPass_Full_Database_Creation_DDL_v1.2.live_schema.sql`.

## Inspection Performed

The live database was inspected with `psql`, `information_schema`, `pg_catalog`, and `pg_dump`.

Captured areas:

- Schemas
- Tables
- Columns, data types, nullability, and defaults
- Primary keys
- Foreign keys
- Unique constraints
- Check constraints
- Indexes
- Enum types and values
- Functions/procedures
- Views
- Triggers
- Sequences
- Extensions

## Live Object Summary

Schemas present:

- `audit`
- `config`
- `core`
- `coupons`
- `discounts`
- `events`
- `gates`
- `identity`
- `integration`
- `merchants`
- `operations`
- `payments`
- `public`
- `reconciliation`
- `sessions`
- `sites`

Base table counts by schema:

| Schema | Tables |
| --- | ---: |
| audit | 4 |
| config | 5 |
| core | 5 |
| coupons | 4 |
| discounts | 3 |
| events | 5 |
| gates | 4 |
| identity | 6 |
| integration | 5 |
| merchants | 4 |
| operations | 5 |
| payments | 6 |
| reconciliation | 5 |
| sessions | 4 |
| sites | 4 |

Other inspected objects:

- Indexes: 432
- Routines/functions: 52
- Triggers: none
- Extensions: `pgcrypto` 1.3, `plpgsql` 1.0

## Reconciliation-Relevant Live Tables

The live schema contains the reconciliation and payment-to-exit evidence tables needed for the current baseline:

- `core.parking_sessions`
- `core.payment_attempts`
- `core.payment_confirmations`
- `core.exit_authorizations`
- `payments.payment_rails`
- `payments.payment_provider_routing_policies`
- `payments.provider_sessions`
- `payments.provider_callbacks`
- `payments.provider_outcomes`
- `gates.gate_authorization_consumptions`
- `gates.gate_events`
- `audit.audit_events`
- `events.domain_events`
- `events.outbox_events`
- `reconciliation.reconciliation_runs`
- `reconciliation.reconciliation_items`
- `reconciliation.reconciliation_exceptions`
- `reconciliation.mops_transaction_records`
- `reconciliation.settlement_comparison_records`

Note: the live provider webhook evidence table is `payments.provider_callbacks`; no separate `payments.provider_webhook_events` table exists in the inspected live schema.

## DDL Synchronization

Schema-only extraction command used:

```powershell
docker exec exitpass-postgres pg_dump `
  -U exitpass `
  -d exitpass_v12_dev `
  --schema-only `
  --no-owner `
  --no-privileges `
  --restrict-key=ExitPassV12SchemaOnlySync `
  -f /tmp/ExitPass_Full_Database_Creation_DDL_v1.2.live_schema.sql
```

Repository files updated from the live extraction:

- `snapshots/ExitPass_Full_Database_Creation_DDL_v1.2.live_schema.sql`
- `snapshots/ExitPass_Full_Database_Creation_DDL_v1.2.sql`
- `migrations/20260512012142_baseline_v1_2.sql`

The stable `--restrict-key` avoids pg_dump random-token churn. The only prior structural difference visible in the working tree was the pg_dump `\restrict` / `\unrestrict` token. The canonical snapshot, live snapshot, and baseline migration now match each other.

## Data Safety

The regenerated DDL is schema-only:

- No volatile runtime rows are included.
- No `WEBPAY-20260524-FRESH-*` ticket data is included.
- No PayMongo secret keys are included.
- No runtime metrics baseline JSON is included.
- No settlement or payout records were generated.

## Patch Script

No patch script was needed. The live database is the source of truth and the repository schema artifacts were aligned to it. No live schema changes were applied.

## Validation Commands

Representative validation commands run:

```powershell
docker exec exitpass-postgres psql -U exitpass -d exitpass_v12_dev -X -v ON_ERROR_STOP=1 -c "SELECT schema_name FROM information_schema.schemata ORDER BY schema_name;"
docker exec exitpass-postgres psql -U exitpass -d exitpass_v12_dev -X -v ON_ERROR_STOP=1 -c "SELECT n.nspname AS schema_name, c.relname AS object_name, c.relkind FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname NOT IN ('pg_catalog','information_schema') AND c.relkind IN ('r','p','v','m','S') ORDER BY n.nspname, c.relkind, c.relname;"
docker exec exitpass-postgres psql -U exitpass -d exitpass_v12_dev -X -v ON_ERROR_STOP=1 -c "SELECT extname, extversion FROM pg_extension ORDER BY extname;"
Compare-Object (Get-Content snapshots\ExitPass_Full_Database_Creation_DDL_v1.2.sql) (Get-Content migrations\20260512012142_baseline_v1_2.sql)
Select-String -Path snapshots\ExitPass_Full_Database_Creation_DDL_v1.2.sql -Pattern "WEBPAY-20260524-FRESH|PAYMONGO_SECRET|PAYMONGO_PUBLIC|AUB" -CaseSensitive
```

## Conclusion

The database repository is synchronized to the current live ExitPass v1.2 schema baseline. Reconciliation-related schemas and the validated WebPay PayMongo payment-to-exit control-chain tables are present in the generated DDL. No AUB routing/configuration/invocation changes were introduced.
