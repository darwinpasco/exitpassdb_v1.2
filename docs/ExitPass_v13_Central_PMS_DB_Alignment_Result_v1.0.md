# ExitPass v1.3 Central PMS DB Alignment Result v1.0

## Result
PASSED for additive schema/object validation against a disposable PostgreSQL database.

This branch adds v1.3 Central PMS alignment objects to the canonical `exitpassdb_v1.2` repository without deleting or weakening v1.2 baseline objects.

## Objects Added

| Area | Additive objects |
| --- | --- |
| Fiscal issuance | `core.fiscal_issuance_references` plus attempt history, exception review, readback reconciliation, retry command/schedule/execution preparation, semantic hash recalculation preview, semantic hash backfill mutation preparation, and semantic hash backfill workflow request tables. |
| Operator Console | `operator_console` schema with HR identity mappings, operator shifts/versions/revocations/takeovers, device bindings/history, access evaluations/reasons, and statutory entitlement fingerprint support. |
| Statutory discounts | `discounts.statutory_discount_payable_basis_applications`, payable-basis application enums, lifecycle trigger, indexes, and traceability columns. |
| Applied tariff lifecycle | Unique applied statutory tariff snapshot index, lifecycle check constraint, and `discounts.apply_statutory_discount_payable_basis(uuid, uuid, uuid)`. |
| Policy import review | Added `operator_console.production_policy_import_review_*` queue tables while preserving existing `discounts.statutory_discount_policy_import_review_*` policy-domain objects. |

## Reference Data / UAT Support

Local/UAT-only seed and verification scripts were added under `scripts/uat`:

- `Seed-ManagementPlatformUatIdentityRbac.sql`
- `Verify-ManagementPlatformUatIdentityRbac.sql`
- `Seed-StatutoryDiscountPilotFixture.sql`
- `Verify-StatutoryDiscountPilotFixture.sql`

These scripts keep UAT users and statutory discount fixture rows separate from baseline production reference data. The Management Platform seed carries the approved seven role bundles and granular permissions/access rights for local/UAT verification.

## Validation Commands

Executed against local Docker container `exitpass-postgres`:

```powershell
docker exec exitpass-postgres psql -U exitpass -d postgres -c "DROP DATABASE IF EXISTS exitpass_v13_alignment_validation WITH (FORCE);"
docker exec exitpass-postgres psql -U exitpass -d postgres -c "CREATE DATABASE exitpass_v13_alignment_validation;"
docker cp D:\SourceCodes\exitpassdb_v1.2\migrations\. exitpass-postgres:/tmp/exitpassdb_v13_migrations
docker exec exitpass-postgres psql -v ON_ERROR_STOP=1 -U exitpass -d exitpass_v13_alignment_validation -f /tmp/exitpassdb_v13_migrations/20260512012142_baseline_v1_2.sql
docker exec exitpass-postgres psql -v ON_ERROR_STOP=1 -U exitpass -d exitpass_v13_alignment_validation -f /tmp/exitpassdb_v13_migrations/20260713090000_v13_central_pms_alignment.sql
docker cp D:\SourceCodes\exitpassdb_v1.2\scripts\validation\Validate-V13CentralPmsAlignment.sql exitpass-postgres:/tmp/Validate-V13CentralPmsAlignment.sql
docker exec exitpass-postgres psql -v ON_ERROR_STOP=1 -U exitpass -d exitpass_v13_alignment_validation -f /tmp/Validate-V13CentralPmsAlignment.sql
```

Validation result:

```text
ExitPass v1.3 Central PMS DB alignment schema validation passed.
```

## Known Remaining Decisions / Gaps

- Atlas CLI was not installed in the Codex environment, so `migrations/atlas.sum` was not refreshed in this run.
- The existing `20260512_restore_v12_constraints_and_payment_routine.sql` migration is not independently replayable after the current baseline because `ck_evidence_links__row_version_positive` already exists in the baseline. Validation therefore used the current baseline plus the new v1.3 alignment migration.
- UAT identity/RBAC and statutory discount fixture scripts are local/UAT-only and were not applied to a shared `exitpass_v12_dev` database during this DB-repo implementation slice.
- Existing `discounts.statutory_discount_policy_import_review_*` objects remain policy-domain baseline objects; `operator_console.production_policy_import_review_*` was added as the Operator Console production policy import review workflow queue required by current Central PMS source.

## Non-goals Preserved

- No POS Server-owned `pos.*` fiscal document tables were added.
- No Central PMS runtime code, Operator Console UI, POS Server source, or payment/fiscal/gate behavior was changed.
- No payment provider, HikCentral, ExitAuthorization, gate, refund/reversal, POS fiscal number allocation, or final BIR rendering behavior was introduced.
- No secrets, tokens, private keys, raw certificates, or raw statutory evidence were seeded.
