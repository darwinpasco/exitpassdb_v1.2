# Statutory Discount Policy Registry Baseline Implementation Notes v1

## Purpose

This note records the ExitPass v1.2 DB baseline implementation for the governed statutory discount policy registry supporting Operator Console production readiness.

The change is repository-only and state-based. It updates the DB baseline artifacts in `D:\SourceCodes\ExitPass_DBv1.2`; it does not apply local database changes and does not add production policy rows.

## Implemented Objects

Added dedicated governed registry table:

- `discounts.statutory_discount_policy_registry`

Retained transitional compatibility table unchanged:

- `discounts.discount_policy_references`

Updated baseline artifacts:

- `schema/schema.sql`
- `schema/02_enums.generated.sql`
- `schema/03_tables.generated.sql`
- `schema/04_foreign_keys.generated.sql`
- `schema/04a_unique_constraints.generated.sql`
- `schema/05_indexes.generated.sql`
- `migrations/20260512012142_baseline_v1_2.sql`
- `migrations/atlas.sum`
- `snapshots/ExitPass_Full_Database_Creation_DDL_v1.2.sql`

The live schema dump snapshot was not regenerated because no live database was changed in this slice.

## Reused Enums

The registry reuses existing discount governance enums where they already exist:

- `discounts.statutory_entitlement_type_enum`
- `discounts.discount_policy_status_enum`
- `discounts.discount_policy_level_enum`
- `discounts.discount_policy_type_enum`
- `discounts.policy_resolution_basis_enum`
- `discounts.discount_evidence_type_enum`

## New Enums

Added PostgreSQL enum types in the `discounts` schema because this repo already models discount controlled values as enum types:

- `discounts.policy_verification_status_enum`
- `discounts.parking_benefit_type_enum`
- `discounts.discount_base_scope_enum`
- `discounts.beneficiary_residency_scope_enum`

The verification values are:

- `LEAD_UNVERIFIED`
- `VERIFIED_SECONDARY`
- `VERIFIED_OFFICIAL`
- `APPROVED_FOR_PILOT`
- `ACTIVE_APPROVED`
- `PROPOSED_ONLY`
- `REJECTED`

## Constraints

Implemented baseline guards for:

- primary key on `statutory_discount_policy_registry_id`
- unique `policy_code`
- uppercase controlled `policy_code` format
- non-empty `source_reference`
- positive `row_version`
- non-negative `free_duration_minutes`
- valid effective window when `effective_to` is present
- required evidence type when `requires_evidence = true`
- review metadata for verified, pilot-approved, and active-approved rows
- approval metadata for pilot-approved and active-approved rows
- `ACTIVE_APPROVED` rows requiring `policy_status = ACTIVE`
- `PROPOSED_ONLY` rows not using `policy_status = ACTIVE`
- legal/source reference requirement for active-approved rows
- local ordinance rows requiring ordinance reference and at least one jurisdiction, site-group, or site scope field
- national fallback rows requiring national law reference
- Senior Citizen national fallback rows requiring `RA 9994`
- PWD national fallback rows requiring `RA 10754`
- Senior Citizen evidence rows requiring `SENIOR_CITIZEN_ID`
- PWD evidence rows requiring `PWD_ID`
- sandbox, test, dev, e2e, and example markers not being allowed for `ACTIVE_APPROVED` production rows

These constraints are intentionally limited to stable governance rules and do not attempt to encode every possible future lawful policy configuration.

## Indexes

Added lookup and governance indexes for:

- entitlement type
- policy status
- verification status
- policy level
- policy type
- policy resolution basis
- jurisdiction id
- jurisdiction code
- site group
- site
- effective window
- active policy lookup
- supersession links
- correlation id

Added a partial unique active national fallback guard by entitlement for `ACTIVE` plus `ACTIVE_APPROVED` plus `NATIONAL_LAW_FALLBACK`.

## Foreign Key Decisions

Added FKs where target tables already exist in the v1.2 baseline:

- `site_group_id` -> `sites.site_groups(site_group_id)`
- `site_id` -> `sites.sites(site_id)`
- reviewed and approved user fields -> `identity.users(user_id)`
- created and updated user fields -> `identity.users(user_id)`
- created and updated service identity fields -> `identity.service_identities(service_identity_id)`
- supersession fields -> `discounts.statutory_discount_policy_registry(statutory_discount_policy_registry_id)`

No FK was added for `jurisdiction_id` because `sites.jurisdictions` is not present in this repo baseline. The registry keeps `jurisdiction_id`, `jurisdiction_code`, and `jurisdiction_name` so the app and future DB slices can bridge to a governed jurisdiction model without blocking this baseline.

## Compatibility Behavior

`discounts.discount_policy_references` remains the transitional compatibility table. Existing `discounts.statutory_discount_validations` FKs still point to `discounts.discount_policy_references`.

Application policy resolution should continue to support compatibility behavior while adding a dedicated-registry query path after this DB baseline is merged.

## Reference Data

No production policy rows were added.

The header-only template from the proposal slice remains the only registry-related reference-data artifact. Production policy rows still require Legal, Product, Compliance, and Operations approval before they can become DB repo reference data or be loaded through a governed admin/import flow.

Sandbox, development, pilot, and sample rows must remain separated from production-active rows and must not use `ACTIVE_APPROVED` unless they are approved production rows.

## Application Repo Impact

After this DB baseline is merged, the application repo likely needs a bounded follow-up slice to:

- update readiness SQL to prefer `discounts.statutory_discount_policy_registry` when present
- update the policy resolution repository query path to use the dedicated registry
- add dedicated-registry fixtures and tests
- expose verification status in audit/reporting where useful
- keep compatibility-table fallback behavior during transition

No application repo files were modified in this slice.

## Validation Plan

Validation for this slice should remain non-mutating unless an explicitly disposable validation database is used:

1. Run `git diff --check`.
2. Inspect changed schema, migration, snapshot, and documentation files.
3. Run repo-appropriate Atlas/state-based validation against a disposable target when available.
4. Rebuild or update local development DB only from the DB repo baseline, not by ad hoc SQL.
5. Run application policy readiness verification after the DB baseline is available to the app environment.
6. Run Central PMS statutory discount policy resolution tests and Operator Console controlled validation.

`scripts/Align-ExitPassV12DbBaseline.ps1` was inspected and is not run as part of this slice because it promotes a live DB schema into baseline artifacts and can drop/recreate the configured clean DB.

## Rollout Position

- GO for sandbox and deterministic fixture validation.
- CONDITIONAL GO for controlled operational pilot only with manually verified, site-approved policy evidence.
- NO-GO for full production statutory discount auto-application until production policy rows are approved, loaded through the governed path, application resolver/readiness logic is aligned to the dedicated registry, and readiness checks pass.

## Follow-Up Slice

Recommended next DB/application integration slice:

- `#256 Operator Console dedicated statutory discount policy registry resolver/readiness alignment`

If DB review requires another DB-only step first, run:

- `#256 ExitPass_DBv1.2 statutory discount policy registry baseline review/validation hardening`
