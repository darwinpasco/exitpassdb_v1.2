# ExitPass Statutory Discount Staged Service-Channel Canonical DB Promotion Result

## Scope

This canonical database-source slice promotes the merged ExitPass v1.3 statutory-discount staged-command and service-channel review database objects from application-local patch posture into `exitpassdb_v1.2` object source.

No application runtime, API DTO, Bruno, WebPay, APT, Operator Console UI, POS Server, statutory formula, VAT, payment finality, fiscal issuance, ExitAuthorization, or gate behavior changed.

## Promoted Object Families

- `discounts.statutory_discount_decision_commands`
- `discounts.statutory_discount_payable_basis_application_commands`
- `operator_console.statutory_discount_service_channel_reviews`
- final additive metadata columns on `discounts.statutory_discount_validations`
- status, result, semantic-source, recovery, uniqueness, linkage, and privacy constraints
- review discovery, idempotency, business identity, validation linkage, and correlation indexes

## Source Patch Mapping

- `ExitPass_OperatorConsoleStatutoryDiscountDecisionConvergence_v1.3.sql` maps to validation metadata columns, constraints, comments, and `ix_stat_disc_validations__decision_v2_fact_presence`.
- `ExitPass_StatutoryDiscountDecisionFacade_v1.3.sql` maps to the canonical decision command table baseline.
- `ExitPass_StatutoryDiscountStagedCanonicalCommands_v1.3.sql` maps to final decision-v2 columns and the application-v1 command table.
- `ExitPass_StatutoryDiscountServiceChannelPendingReviewIntake_v1.3.sql` maps to final `AWAITING_REVIEW`, `NOT_DECIDED`, and pending-review recovery constraints.
- `ExitPass_StatutoryDiscountServiceChannelOperatorConsoleReviewLinkage_v1.3.sql` maps to the service-channel review table and review queue indexes.
- `ExitPass_StatutoryDiscountServiceChannelPostApprovalApplicationIntent_v1.3.sql` maps to review-to-validation linkage and indexes.

## Canonical Layout

Object source lives under `objects/schemas/discounts` and `objects/schemas/operator_console`, is included in `objects/exitpass-full-object-apply-order.txt`, and is also included in `objects/v13-central-pms-object-apply-order.txt` where it belongs to the v1.3 Central PMS alignment set.

Generated outputs are refreshed from object source through the repository build scripts. Generated SQL is not the primary source.

## Migration Posture

`migrations/20260727090000_statutory_discount_staged_service_channel_canonical_promotion.sql` is additive. It supports a clean pre-promotion canonical baseline and an environment that already applied the six application-local statutory patches.

The migration does not drop data, does not recreate authoritative legacy payable-basis objects, and does not reinterpret historical decision-v1 rows.

## Validation Result

- Clean canonical rebuild from `build/generated/exitpass-full-object.generated.sql` passed Central PMS alignment validation and focused promoted-object checks.
- Pre-promotion canonical upgrade using the additive migration passed; reapplying the migration also passed.
- App-local-patched environment upgrade using the six active statutory patches followed by the additive migration passed; reapplying the migration also passed.
- Focused Central PMS statutory, payment, TerminalCash, fiscal mapper, and fiscal semantic-hash tests passed against a disposable database created from the promoted canonical generated SQL.
- Validation used PostgreSQL 16.14 in disposable databases and did not modify `exitpass_v12_dev`.

## Remaining Work

- Retire superseded app-local statutory patches in `ExitPass-Discounts` after this canonical DB promotion merges.
- Align application integration fixtures so canonical generated SQL is the baseline and retired patches are not reapplied.
- Re-run channel-safe readback hardening only after application patch retirement and fixture alignment.

## Authorization

This database promotion does not authorize WebPay or APT integration.

WebPay integration: not authorized yet
APT integration: not authorized yet
