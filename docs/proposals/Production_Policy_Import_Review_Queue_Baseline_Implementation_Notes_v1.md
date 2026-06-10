# Production Policy Import Review Queue Baseline Implementation Notes v1

## Purpose

This note records the ExitPass v1.2 DB baseline implementation for the Operator Console production statutory discount policy import review queue.

The change is repository-only and state-based. It supports maker/checker review persistence after dry-run validation and before any approved candidate policy rows are aligned into DB reference data or activated through a future governed process.

## Implemented Objects

Added review queue storage in the `discounts` schema:

- `discounts.statutory_discount_policy_import_review_submissions`
- `discounts.statutory_discount_policy_import_review_decisions`
- `discounts.statutory_discount_policy_import_review_findings`
- `discounts.statutory_discount_policy_import_review_history`

Added supporting enum types:

- `discounts.policy_import_review_status_enum`
- `discounts.policy_import_review_role_enum`
- `discounts.policy_import_review_action_enum`
- `discounts.policy_import_review_finding_severity_enum`
- `discounts.policy_import_review_row_decision_enum`

Updated baseline artifacts:

- `schema/schema.sql`
- `schema/02_enums.generated.sql`
- `schema/03_tables.generated.sql`
- `schema/04_foreign_keys.generated.sql`
- `schema/04a_unique_constraints.generated.sql`
- `schema/05_indexes.generated.sql`
- `migrations/20260512012142_baseline_v1_2.sql`
- `snapshots/ExitPass_Full_Database_Creation_DDL_v1.2.sql`

`migrations/atlas.sum` was not regenerated because the Atlas CLI is not available in this local environment.

## Constraints

The baseline includes guards for:

- unique `submission_code`
- non-negative dry-run summary counts
- `APPROVED_FOR_DB_REPO_ALIGNMENT` blocked when `fail_count > 0`
- terminal statuses requiring `closed_at`
- valid SHA-256 source file hash format when present
- JSON shape for sanitized dry-run summary and row results
- positive `row_version`
- rejection and request-changes decisions requiring a reason
- row finding number, finding code, and message validity
- history event type, summary, and sanitized JSON payload shape

The status and action enums intentionally do not include import, activation, apply, seed, or production-auto-application actions.

## Indexes

Added lookup indexes for:

- submission status
- submitter user
- created and submitted timestamps
- source file hash
- correlation id
- supersession link
- decision submission id
- decision reviewer role
- decision timestamp
- finding submission id
- finding policy code
- finding severity
- history submission id
- history actor, timestamp, and correlation id

Added a partial unique index so each approval role can approve a review submission only once.

## Foreign Keys

Added FKs to existing stable tables only:

- review submitter and reviewers -> `identity.users(user_id)`
- review decisions, findings, and history -> `discounts.statutory_discount_policy_import_review_submissions(review_submission_id)`
- superseded review submission -> `discounts.statutory_discount_policy_import_review_submissions(review_submission_id)`

No FK was added to `discounts.statutory_discount_policy_registry` because this queue does not import or activate policy rows.

## Safety Position

No production statutory discount policy rows were added.

No stored procedure, trigger, status, or action was added that imports, applies, seeds, activates, or approves production statutory discount auto-application.

The JSON columns are explicitly for sanitized dry-run data only and must not contain raw CSV, raw evidence, personal data, secrets, production IDs, private keys, or production credentials.

## Validation Notes

Static validation should include:

1. `git diff --check`
2. Search for the new tables/enums in schema, generated files, migration, and snapshot artifacts.
3. Search reference data for absence of production policy rows.
4. Search review action/status enums for absence of import or activation semantics.
5. Run Atlas hash/schema validation in an environment with the Atlas CLI.
6. Optionally rebuild into a disposable database from the baseline migration.

No local application database was changed in this slice.

## Follow-Up Slice

Recommended next slice:

- `#266 Operator Console production policy import review queue persistence/API integration`
