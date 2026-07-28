# ExitPass Statutory Discount Local Ordinance Policy Authority Canonical DB Promotion Result v1.0

## Purpose

This promotion adds the canonical database authority needed for the first jurisdiction-based statutory parking eligibility gate. It is a database-only slice. It does not implement Central PMS runtime eligibility resolution, availability APIs, WebPay or APT consumers, Operator Console UI, benefit-effect calculations, POS fiscal changes, or secure ID-image capture.

## Authoritative Baseline

The authoritative executable baseline is `build/generated/exitpass-full-object.generated.sql` in `D:\SourceCodes\exitpassdb_v1.2`.

The retired `D:\SourceCodes\ExitPass_DBv1.2` repository and `ExitPass_Full_Database_Creation_DDL_v1.2.sql` were not used as schema authority.

## Source Application Gap

The application audit found that statutory Senior Citizen and PWD parking requests could enter the canonical decision workflow without a durable local-ordinance authority model. The required sequence is:

`parking session -> Site -> canonical city or municipality -> active applicable local parking policy -> covered entitlement -> policy requirements -> evidence collection -> Operator Console review -> canonical decision -> payable-basis application -> payment and fiscal linkage`.

This promotion closes the canonical database representation gap. Runtime enforcement remains a separate Central PMS task.

## Objects Added Or Changed

Added `sites.jurisdictions` for canonical city and municipality identity, including jurisdiction code, type, display name, province, region, PSGC where available, status, effective dating, replacement, source provenance, and audit fields.

Added `sites.site_jurisdiction_assignments` for deterministic effective Site-to-jurisdiction assignment with historical retention and active open-assignment uniqueness.

Added immutable policy-version authority under `discounts.statutory_discount_policy_versions`, with normalized evidence requirements and policy relationships.

Added `discounts.statutory_discount_decision_policy_authorities` to freeze governing policy authority on a statutory decision.

Added nullable policy-authority linkage columns to statutory validation, payable-basis application command, and Operator Console service-channel review records.

Updated the legacy policy registry local-scope constraint so compatibility rows require local scope but do not force fabricated ordinance references. Source and ordinance availability now live in policy-version authority fields.

## Model Summary

Jurisdiction is not inferred from display names. `sites.sites.lgu_code` remains a compatibility projection and is not the authoritative transaction-use resolver.

Policy verification and transaction-use publication are separate. `VERIFIED_ACTIVE_OPERATIONAL` can represent confirmed operational authority without online ordinance text or known ordinance number, but a policy is not transaction usable unless its publication state is active for transaction use and approval metadata is present.

Official source availability, ordinance text availability, ordinance number availability, ordinance title availability, and detailed-rule verification are independent facts.

Parking-service applicability is explicit and structured. Entitlement coverage is queryable by entitlement type and does not assume every ordinance covers both Senior Citizen and PWD.

Benefit effect is classified without adding calculation SQL. Full-fee exemption, free duration, initial-rate exemption, capped benefit, unsupported effect, and unresolved effect can be represented without mapping free parking to a 20% discount.

Residency scope and required evidence are represented structurally. No raw evidence or image storage was added.

Policy relationships support amendment, replacement, clarification, and supersession. Validation detects unresolved overlap for transaction-active policy versions with the same jurisdiction, entitlement, scope, and precedence.

## Durable Linkage

Decision policy authority freezes jurisdiction, policy version, verification state, publication state, parking applicability, benefit type, residency scope, source availability posture, effective window, policy semantic hash, and resolution timestamp.

Application and review records can link to the same policy version and decision policy authority. The application path can therefore consume the decision-bound policy authority instead of independently resolving a newer ordinance version.

## Parañaque Representation

The model can represent Parañaque City Senior Citizen and PWD resident-only free-parking benefits as `VERIFIED_ACTIVE_OPERATIONAL`, active for controlled transaction use, with official online source unavailable and ordinance text unavailable.

The Senior Citizen ordinance number remains null or unavailable. Unknown details such as enactment date, exclusions, free-parking duration, valet treatment, overnight treatment, lost-ticket treatment, facility-specific scope, and vehicle-use rules are preserved as unknown rather than false, zero, unlimited, or not applicable.

No production Parañaque seed data was added because controlled Site IDs, approval references, stable policy identifiers, and production data-assignment authority are not part of this promotion.

## Non-Active Policy Examples

The validation fixture proves that a Mandaue proposed PWD policy can be represented without becoming transaction-active.

The model can represent Taytay unverified leads, Malolos limited or unresolved scope, explicit no-local-rule records, expired policies, suspended policies, superseded policies, and overlapping conflicts. Transaction activation is blocked for proposed, unverified, no-local-rule, suspended, withdrawn, retired, superseded, and unresolved policy states unless a valid active successor or separate approved authority exists.

## Compatibility

The migration is additive and rerunnable. Existing statutory policy, validation, decision, review, and payable-basis application rows remain readable. Existing `lgu_code` values are not reinterpreted or mapped automatically.

When existing data cannot be mapped to a canonical jurisdiction, the runtime must treat it as unresolved and fail closed for statutory benefit eligibility until controlled data assignment is completed.

## Migration Behavior

The migration adds enum labels, new tables, nullable linkage columns, constraints, and indexes. It preserves existing rows and does not fabricate jurisdiction mapping or policy authority.

Upgrade from the pre-change `origin/develop` generated baseline succeeded. Rerunning the migration succeeded with expected "already exists" notices.

## Validation

Validation used Docker PostgreSQL:

- Image: `postgres:16-alpine`
- Container: `exitpass-postgres`
- Host port: `5433`
- Clean rebuild database: `exitpass_policy_authority_validation`
- Upgrade database: `exitpass_policy_authority_upgrade_validation`

Validated:

- canonical SQL generation
- full object source layout
- v1.3 Central PMS object source layout
- object-source coverage
- clean disposable PostgreSQL rebuild
- Central PMS alignment validation
- upgrade from pre-change generated baseline
- migration rerun
- focused policy-authority structural validation
- Parañaque active-operational representation
- Mandaue proposed-policy rejection
- proposed and no-local-rule active-transaction rejection

## Known Data-Assignment Gaps

Production seed data still requires controlled assignment of canonical jurisdiction records, Site-to-jurisdiction mappings, approved policy identifiers, approval references, policy effective dates where known, source provenance, and policy-version semantic hashes. Missing facts must remain null or unresolved until product, legal, or data-governance authority supplies them.

## Exact Next Runtime Task

Implement the Central PMS local-ordinance eligibility gate using the promoted canonical model:

1. Resolve parking session to Site.
2. Resolve Site to canonical jurisdiction.
3. Resolve an active transaction-use policy version by jurisdiction, entitlement, Site/Site Group scope, transaction instant, publication, verification, and parking applicability.
4. Return a channel-safe availability contract.
5. Enforce the same resolver before statutory decision creation.
6. Freeze the resolved decision policy authority.
7. Surface safe policy facts to Operator Console backend readback.

## Sequencing Decision

READY_FOR_CENTRAL_PMS_LOCAL_ORDINANCE_ELIGIBILITY_GATE

## Final Authorization Lines

WebPay integration: not authorized yet
APT integration: not authorized yet
