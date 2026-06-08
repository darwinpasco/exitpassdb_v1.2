# Statutory Discount Policy Registry Baseline Proposal v1

## Purpose

This document proposes the ExitPass v1.2 DB baseline shape for a governed statutory discount policy registry supporting Operator Console statutory discount production rollout.

The target state is a state-based DB baseline change in this repository, `D:\SourceCodes\ExitPass_DBv1.2`. This slice is proposal-only: it does not apply local database changes, does not edit generated baseline schema files, does not add migrations or snapshots, and does not add production policy rows.

Production statutory discount auto-application remains NO-GO until the governed registry baseline, approved production policy data strategy, application resolver alignment, and readiness verification are complete.

## Current State

Repository inspection:

- Current branch was created from the active live-aligned baseline tag `db-v1.2.0-live-aligned`.
- No local `main` branch was checked out; `origin/main` exists, and the active checked-out baseline was the live-aligned detached state.
- `atlas.hcl` points Atlas at `schema/schema.sql` and `migrations`.
- `schema/schema.sql` is the composed state-based schema source.
- `schema/02_enums.generated.sql`, `schema/03_tables.generated.sql`, `schema/04_foreign_keys.generated.sql`, `schema/04a_unique_constraints.generated.sql`, and `schema/05_indexes.generated.sql` are generated schema artifacts.
- `migrations/20260512012142_baseline_v1_2.sql` and `snapshots/ExitPass_Full_Database_Creation_DDL_v1.2.sql` hold the baseline DDL.
- `scripts/Align-ExitPassV12DbBaseline.ps1` promotes live schema into the baseline and verifies Atlas drift.
- `reference-data/ExitPass_Reference_Data_v1.2.sql` contains local development and integration testing reference data and explicitly says not to store legal production policy data there.

Existing statutory discount baseline:

- `discounts.discount_policy_references` exists and is the current compatibility table.
- `discounts.statutory_discount_policy_registry` is absent.
- `discounts.policy_verification_status_enum` is absent.
- Dedicated benefit, residency, and discount-base enums for the governed registry are absent.
- `sites.jurisdictions` is absent; current site jurisdiction support is represented by fields such as `sites.sites.lgu_code`.
- Existing `discounts.statutory_discount_validations` references `discounts.discount_policy_references`.
- Reference data includes development placeholder policy rows such as `PH_NATIONAL_SENIOR_DEV`, `PH_NATIONAL_PWD_DEV`, `MNT_LOCAL_SENIOR_DEV`, and `MNT_LOCAL_PWD_DEV`.

Application-side context read-only inputs:

- Operator Console readiness and fail-closed behavior exists in the application repo.
- Application readiness SQL currently detects whether `discounts.statutory_discount_policy_registry` exists and otherwise inspects `discounts.discount_policy_references`.
- Import validation rules define a controlled candidate policy contract, but passing validation does not approve a row for production.
- Production Senior Citizen and PWD policy rows remain missing after sandbox/dev rows are excluded.

## Target Registry Recommendation

Use the hybrid transition:

- Add a governed dedicated `discounts.statutory_discount_policy_registry` to the DB baseline.
- Retain `discounts.discount_policy_references` during transition.
- Keep application readiness scripts compatible with the old table while adding dedicated-registry checks.
- Update application policy resolution to prefer the dedicated registry when present.
- Deprecate compatibility-only production policy use after the dedicated registry is proven.

The dedicated registry is required because the compatibility table does not represent verification status, source approval, benefit behavior, residency scope, exclusion flags, approval metadata, source hashes, or policy supersession with enough precision for production statutory discount auto-application.

## Proposed Schema Objects

Future implementation slice should update state-based baseline artifacts, not local DB state:

- `discounts.statutory_discount_policy_registry`
- Registry enum types or controlled-code sets for verification status, benefit type, discount base scope, and beneficiary residency scope
- Optional `sites.jurisdictions` or an equivalent governed jurisdiction registry
- Optional `sites.sites.jurisdiction_id` if a normalized jurisdiction table is approved
- FKs from registry rows to `sites.site_groups`, `sites.sites`, `identity.users`, and `identity.service_identities` where consistent with existing conventions
- Optional links from `discounts.statutory_discount_validations` to the dedicated registry after application resolver design is approved
- Indexes and constraints described below

Because this repo does not have an established proposal-SQL convention and uses generated/baseline SQL artifacts, this slice does not add a draft DDL file. The implementation slice should update the source-of-truth schema path first and regenerate or promote generated schema, baseline migration, and snapshots according to repo workflow.

## Proposed Registry Table Model

Target table: `discounts.statutory_discount_policy_registry`.

Recommended columns, adapted to repo naming conventions:

| Column | Proposed type | Notes |
| --- | --- | --- |
| `statutory_discount_policy_registry_id` | `uuid` | Primary key. If implementation prefers shorter naming, `statutory_discount_policy_id` is acceptable if app alignment agrees. |
| `policy_code` | `varchar(128)` | Stable unique controlled code. |
| `policy_name` | `varchar(256)` | Human-readable name. |
| `policy_description` | `text` | Optional descriptive text. |
| `entitlement_type` | `discounts.statutory_entitlement_type_enum` | Existing enum: `SENIOR_CITIZEN`, `PWD`, `OTHER_STATUTORY`. |
| `policy_status` | existing enum or new controlled status | Prefer existing `discounts.discount_policy_status_enum` only if `ACTIVE_APPROVED` is modeled separately in `verification_status`. |
| `verification_status` | new enum or controlled code | Source/review state. |
| `policy_level` | `discounts.discount_policy_level_enum` | Existing enum. |
| `policy_type` | `discounts.discount_policy_type_enum` | Existing enum. |
| `policy_resolution_basis` | `discounts.policy_resolution_basis_enum` | Existing enum. |
| `benefit_type` | new enum or controlled code | Benefit behavior. |
| `discount_base_scope` | new enum or controlled code | Discount computation basis. |
| `jurisdiction_id` | `uuid` | Nullable FK if normalized jurisdictions are added. |
| `jurisdiction_code` | `varchar(64)` | Nullable bridge code for LGU/PSGC or approved internal code. |
| `jurisdiction_name` | `varchar(160)` | Nullable display name. |
| `site_group_id` | `uuid` | Nullable FK to `sites.site_groups`. |
| `site_id` | `uuid` | Nullable FK to `sites.sites`. |
| `beneficiary_residency_scope` | new enum or controlled code | Residency eligibility. |
| `facility_scope` | `text` | Optional facility limitations. |
| `free_duration_minutes` | `integer` | Nullable, non-negative. |
| `initial_rate_exempt` | `boolean` | Default false. |
| `full_fee_exempt` | `boolean` | Default false. |
| `overnight_excluded` | `boolean` | Default false. |
| `valet_excluded` | `boolean` | Default false. |
| `standalone_parking_excluded` | `boolean` | Default false. |
| `driver_or_passenger_required` | `boolean` | Default false. |
| `requires_evidence` | `boolean` | Default true for Operator Console-controlled rows unless exempted. |
| `required_evidence_type` | `discounts.discount_evidence_type_enum` | Nullable only when evidence is not required. |
| `requires_operator_validation` | `boolean` | Default true for Operator Console-controlled rows. |
| `legal_basis_reference` | `varchar(256)` | Nullable general legal reference. |
| `ordinance_reference` | `varchar(256)` | Required for local ordinance rows. |
| `national_law_reference` | `varchar(128)` | Required for national fallback rows. |
| `source_reference` | `text` | Required source/control reference. |
| `source_document_hash` | `varchar(128)` | Optional hash of reviewed source document. |
| `reviewed_by_user_id` | `uuid` | Nullable FK to `identity.users` if human reviewer is represented. |
| `reviewed_by` | `varchar(128)` | Optional text fallback if reviewer is external/manual. |
| `reviewed_at` | `timestamptz` | Required for reviewed states. |
| `approved_by_user_id` | `uuid` | Nullable FK to `identity.users` if human approver is represented. |
| `approved_by` | `varchar(128)` | Optional text fallback if approver is external/manual. |
| `approved_at` | `timestamptz` | Required for pilot/active-approved states. |
| `effective_from` | `timestamptz` | Required. |
| `effective_to` | `timestamptz` | Nullable. |
| `supersedes_policy_id` | `uuid` | Nullable self-FK. |
| `superseded_by_policy_id` | `uuid` | Nullable self-FK. |
| `notes` | `text` | Non-sensitive notes only. |
| `created_at` | `timestamptz` | Default `now()`. |
| `created_by_user_id` | `uuid` | Nullable FK. |
| `created_by_service_identity_id` | `uuid` | Nullable FK. |
| `updated_at` | `timestamptz` | Default `now()`. |
| `updated_by_user_id` | `uuid` | Nullable FK. |
| `updated_by_service_identity_id` | `uuid` | Nullable FK. |
| `correlation_id` | `uuid` | Nullable trace reference. |
| `row_version` | `bigint` | Default `1`, positive check. |

## Proposed Enums And Controlled Values

The repo currently uses PostgreSQL enums for many domain values and also has `config.controlled_code_sets`. Implementation should decide enum versus controlled code before changing baseline schema.

Recommended default: use PostgreSQL enums for core resolver-critical values that must be strongly constrained at write time, and optionally mirror them in `config.controlled_code_sets` for UI/import display if needed.

Proposed `verification_status` values:

- `LEAD_UNVERIFIED`
- `VERIFIED_SECONDARY`
- `VERIFIED_OFFICIAL`
- `APPROVED_FOR_PILOT`
- `ACTIVE_APPROVED`
- `PROPOSED_ONLY`
- `REJECTED`

Proposed `beneficiary_residency_scope` values:

- `RESIDENT_ONLY`
- `NON_RESIDENT_ALLOWED`
- `MIXED_OR_CONFLICTING`
- `UNVERIFIED`
- `NOT_APPLICABLE`

Proposed `discount_base_scope` values:

- `VAT_EXCLUSIVE`
- `GROSS`
- `NET`
- `NOT_APPLICABLE`

Proposed `benefit_type` values:

- `STATUTORY_DISCOUNT_VAT_EXEMPT`
- `FREE_DURATION`
- `INITIAL_RATE_EXEMPTION`
- `FULL_FEE_EXEMPTION`
- `LOCAL_RULE`
- `MANUAL_REVIEW`

Existing enums to reuse:

- `discounts.statutory_entitlement_type_enum`
- `discounts.discount_policy_level_enum`
- `discounts.discount_policy_type_enum`
- `discounts.policy_resolution_basis_enum`
- `discounts.discount_evidence_type_enum`

Open alignment item: the earlier app patch used `MIXED`, `FULL_PARKING_FEE`, and `CHARGEABLE_PORTION_ONLY`; the import validation contract uses `MIXED_OR_CONFLICTING`, `VAT_EXCLUSIVE`, `GROSS`, and `NET`. The implementation slice should prefer the import validation contract unless DB architecture rejects those terms.

## Proposed Constraints

Recommended constraints for implementation:

- Primary key on `statutory_discount_policy_registry_id`.
- Unique `policy_code`.
- `policy_code` must be non-blank and uppercase controlled-code shaped.
- `effective_to > effective_from` when `effective_to` is not null.
- `source_reference` is required.
- `row_version > 0`.
- `free_duration_minutes >= 0` when present.
- Reviewed or approved rows require `reviewed_by_user_id` or `reviewed_by`, plus `reviewed_at`.
- `APPROVED_FOR_PILOT` and `ACTIVE_APPROVED` rows require `approved_by_user_id` or `approved_by`, plus `approved_at`.
- `ACTIVE_APPROVED` rows require at least one of `legal_basis_reference`, `ordinance_reference`, or `national_law_reference`.
- `LOCAL_ORDINANCE` or `LOCAL_ORDINANCE_APPLIED` rows require `ordinance_reference`.
- National fallback rows require `national_law_reference`.
- Senior Citizen national fallback rows require `national_law_reference = 'RA 9994'`.
- PWD national fallback rows require `national_law_reference = 'RA 10754'`.
- `requires_evidence = true` requires `required_evidence_type`.
- Senior Citizen evidence, where required, should use `SENIOR_CITIZEN_ID` unless a formal exception is represented.
- PWD evidence, where required, should use `PWD_ID` unless a formal exception is represented.
- `PROPOSED_ONLY`, `LEAD_UNVERIFIED`, and `REJECTED` must not be treated as active-approved.
- Sandbox/test/dev/E2E markers should be blocked from `ACTIVE_APPROVED` production rows if enforceable with a check constraint or validation trigger.
- Local ordinance rows require at least one explicit scope: `jurisdiction_id`, `jurisdiction_code`, `site_group_id`, or `site_id`.
- Active uniqueness guard by entitlement plus scope plus effective period should be implemented where feasible.
- Supersession links should reference existing registry rows and should not form direct self-reference cycles.

Effective-period overlap exclusion is difficult with nullable, multi-column scope in plain unique indexes. Implementation should decide between a pragmatic partial unique index for common active scopes, a PostgreSQL exclusion constraint, or an application/admin validation rule.

## Proposed Indexes

Recommended indexes:

- Unique index or constraint on `policy_code`.
- `entitlement_type`.
- `policy_status`.
- `verification_status`.
- `policy_level`.
- `policy_type`.
- `policy_resolution_basis`.
- `jurisdiction_id`.
- `jurisdiction_code`.
- `site_group_id`.
- `site_id`.
- `effective_from, effective_to`.
- `correlation_id` where not null.
- `supersedes_policy_id` and `superseded_by_policy_id` where not null.
- Composite active lookup index for resolver path:
  - `entitlement_type`
  - `policy_resolution_basis`
  - `verification_status`
  - `jurisdiction_id` or `jurisdiction_code`
  - `site_group_id`
  - `site_id`
  - `effective_from`
  - `effective_to`

Recommended partial unique indexes:

- One active-approved national fallback row per entitlement where `policy_resolution_basis = 'NATIONAL_LAW_FALLBACK'`.
- One active-approved local policy per entitlement and exact jurisdiction/site/site-group scope where feasible.

## Reference Data Strategy

No production policy rows are added in this slice.

Recommended strategy:

- Keep `reference-data/ExitPass_Reference_Data_v1.2.sql` as local development and integration testing baseline data unless a separate approved production reference-data path is created.
- Add production policy rows to DB repo reference data only after Legal/Product/Compliance/Ops approval.
- Approved rows must be traceable to reviewed source references and approval metadata.
- Sandbox/dev/pilot rows must be clearly separated from production-active rows.
- Pilot rows should use `APPROVED_FOR_PILOT`, not `ACTIVE_APPROVED`.
- `ACTIVE_APPROVED` must mean production-approved, not merely enabled in development.
- Do not promote ad hoc local rows or application fixture rows into baseline.

This proposal adds a header-only template at `reference-data/templates/statutory_discount_policy_registry_template.csv`. It is not seed data and must not be interpreted as production policy approval.

## Compatibility Transition

`discounts.discount_policy_references` remains transitional.

Transition plan:

1. Add the dedicated registry to the DB baseline while retaining the compatibility table.
2. Keep existing FK paths from `discounts.statutory_discount_validations` to `discounts.discount_policy_references` until application resolver and validation snapshot design is approved.
3. Add dedicated-registry query/readiness support in the application repo.
4. Compare dedicated registry readiness output against compatibility-table readiness output during controlled validation.
5. Stop using compatibility-only production policy rows after the dedicated registry is populated with approved rows and the app resolver prefers it.

Deprecation criteria for compatibility-only production use:

- Dedicated registry exists in the state-based DB baseline.
- Approved policy rows, if any, are governed in DB repo reference data or through an approved admin/import workflow.
- Application readiness checks pass against the dedicated registry.
- Resolver tests cover dedicated-registry paths.
- Operator Console controlled validation passes with no payment, gate, coupon, or reconciliation mutation.

## Validation Approach

Future implementation validation should include:

1. Update the state-based schema source and generated artifacts according to repo convention.
2. Regenerate or update baseline migration and snapshots according to the established workflow.
3. Run `git diff --check`.
4. Run Atlas/state-based validation using `atlas.hcl`.
5. Rebuild a clean local DB from the repo baseline.
6. Compare the clean rebuild with the expected target database.
7. Run the application repo policy readiness wrapper after DB alignment.
8. Run Central PMS policy resolution tests.
9. Run Operator Console statutory discount controlled validation.
10. Verify no payment, provider, WebPay, AUB, coupon, reconciliation, HikCentral, or gate behavior changed.

This proposal slice did not connect to a database and did not execute SQL.

## Atlas And State-Based Workflow

Observed workflow:

- `atlas.hcl` uses `schema/schema.sql` as the schema source.
- Baseline migration and snapshots are used as promoted schema artifacts.
- `scripts/Align-ExitPassV12DbBaseline.ps1` can promote live schema into baseline and compare with Atlas.
- Several files are generated or promoted from schema dumps.

Implementation guidance:

- Do not hand-edit generated files unless that is the accepted implementation method for this repo.
- If a source-of-truth schema generation step exists outside this repo, update that first.
- If the repo has no generator available, document manual edits explicitly in the implementation slice and update all affected baseline artifacts consistently.
- Do not use local DB changes as the source of truth unless the team explicitly chooses the existing live-alignment script workflow and records the drift evidence.

## Rollout And Go/No-Go Position

- GO for sandbox and deterministic fixture validation.
- CONDITIONAL GO for controlled operational pilot only with manually verified site-approved policy evidence.
- NO-GO for full production statutory discount auto-application until the governed DB baseline, verified production policy rows, application resolver alignment, and readiness verification are complete.

Production auto-application must remain blocked when policies are missing, sandbox/dev-only, unverified, inactive, expired, unscoped, missing evidence rules, or not aligned with the DB repo baseline.

## Risks

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Compatibility table remains the only production policy source. | Production policy rows lack governance fields. | Add dedicated registry and app preferred query path. |
| Enums diverge from import validation rules. | Import candidates may not map cleanly to DB. | Resolve enum/control-code decisions before implementation. |
| Production rows are inserted ad hoc. | Baseline becomes unreproducible. | Require DB repo or approved admin/import workflow. |
| Local ordinance rows are encoded from unverified sources. | Incorrect statutory benefit could auto-apply. | Require Legal/Compliance source review and approval metadata. |
| Duplicate active policies overlap by scope/effective period. | Resolver may select wrong policy. | Add uniqueness/exclusion constraints and admin validation. |
| Compatibility and dedicated registry disagree during transition. | Split-brain policy readiness. | Run dual readiness checks until deprecation criteria are met. |

## Open Decisions

- Whether verification and benefit values should be PostgreSQL enums, `config.controlled_code_sets`, or both.
- Whether to add normalized `sites.jurisdictions` now or use `jurisdiction_code`/`jurisdiction_name` first.
- Whether national fallback rows for RA 9994 and RA 10754 belong in baseline reference data or admin/import flow.
- Whether the registry primary key should be `statutory_discount_policy_registry_id` or `statutory_discount_policy_id`.
- Whether approved/reviewed actor fields should be UUID-only, text-only, or both.
- Whether validations should link directly to the dedicated registry in the same implementation slice or after resolver changes.
- How to enforce overlapping effective-period uniqueness across nullable scope fields.
- Whether to keep development placeholder rows in `discounts.discount_policy_references` after dedicated registry rollout.

## DB Change Decision

Database changes required for production rollout: yes.

Database changes performed in this slice: no.

Artifacts added in this slice:

- Proposal markdown document.
- Header-only registry reference-data template.

Artifacts not added in this slice:

- No applied DDL.
- No migration.
- No generated schema edits.
- No snapshots.
- No production policy rows.
- No proposal SQL, because this repo does not currently show a proposal-SQL convention and its SQL files are baseline/migration/generated artifacts.

Follow-up implementation slice required: yes.

## Next Slice Recommendation

Recommended next slice: #255 ExitPass_DBv1.2 statutory discount policy registry baseline implementation.

If architecture review approval is required before DB implementation, insert a review-approval slice first. Otherwise, #255 should update the DB repo baseline artifacts consistently and validate with the repo's Atlas/state-based workflow.

## Boundary Confirmations

- No application repo changes.
- No local DB state changes.
- No SQL execution.
- No production policy rows added.
- No backend behavior changes.
- No frontend behavior changes.
- No payment/provider/WebPay/AUB/coupon/reconciliation/HikCentral/gate changes.
- No sensitive credentials, production IDs, private keys, raw evidence, or personal data added.
