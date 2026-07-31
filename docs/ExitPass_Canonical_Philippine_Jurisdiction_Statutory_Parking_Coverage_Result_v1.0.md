# ExitPass Canonical Philippine Jurisdiction Statutory Parking Coverage Result v1.0

## Purpose

This change promotes a canonical Philippine jurisdiction and statutory parking coverage model for current Professional Parking Group reference coverage work. It lets a local statutory parking policy be represented once at city or municipality level, then resolved through the Site's authoritative local government unit assignment.

This result is database-only. It does not authorize WebPay, APT, POS Server, controlled UAT, production rollout, automatic statutory application, policy administration UI, or runtime benefit calculation changes.

## Authoritative Baseline

The source baseline is `origin/develop` in `D:\SourceCodes\exitpassdb_v1.2`.

The generated SQL authority remains:

`build/generated/exitpass-full-object.generated.sql`

The retired `D:\SourceCodes\ExitPass_DBv1.2` repository was not used.

## Geographic Hierarchy

The model separates:

- region
- province, when applicable
- city or municipality

National Capital Region LGUs are assigned to the National Capital Region and have `philippine_province_id = null`. Metro Manila is not represented as a province.

Highly urbanized or administratively independent cities can have a nullable province reference while retaining the official PSGC code as their external geographic authority.

## Objects Added

The `sites` schema adds:

- `sites.philippine_regions`
- `sites.philippine_provinces`
- `sites.city_classification_enum`
- `sites.metropolitan_areas`
- `sites.metropolitan_area_jurisdictions`
- `sites.site_group_lgu_scopes`

The `discounts` schema adds:

- `discounts.statutory_discount_policy_registry_lgu_scopes`
- `discounts.statutory_parking_lgu_policy_coverage`
- `discounts.statutory_parking_site_policy_coverage`

## Objects Extended

`sites.jurisdictions` is extended with Philippine region, province, PSGC correspondence, short display, and city-classification fields. It remains the canonical LGU table for cities and municipalities.

`sites.sites` is extended with `local_government_unit_id`. Existing compatibility fields `city`, `province`, and `lgu_code` remain.

`discounts.statutory_discount_policy_registry` is extended with `local_government_unit_id`, `coverage_available`, `auto_application_allowed`, `source_scan_date`, and `source_document_available`.

`discounts.statutory_discount_policy_versions` is extended with `local_government_unit_id` for durable compatibility with policy-version resolution.

## Site Authority

The authoritative Site jurisdiction field is:

`sites.sites.local_government_unit_id`

New synthetic Sites must have exactly one LGU assignment. Legacy text columns remain compatibility projections and must not be silently reinterpreted.

## Site Group Jurisdiction

Site Group jurisdiction coverage is derived through:

`sites.site_group_lgu_scopes`

A Site Group may span multiple LGUs. Site Group is an administrative/query scope and is not the legal source of an ordinance.

## Policy Inheritance

Statutory parking policy research rows are assigned to LGUs through:

- `discounts.statutory_discount_policy_registry.local_government_unit_id`
- `discounts.statutory_discount_policy_registry_lgu_scopes`

The read model `discounts.statutory_parking_site_policy_coverage` proves ordinary Site inheritance from the Site's LGU without duplicating city-level policy rows for every Site.

## Verification And Lifecycle

Research verification remains separate from transaction lifecycle. Seeded research rows use existing verification classifications including:

- `VERIFIED_OFFICIAL`
- `VERIFIED_ACTIVE_OPERATIONAL`
- `VERIFIED_SECONDARY`
- `LEAD_UNVERIFIED`
- `PROPOSED`
- `NO_LOCAL_RULE_FOUND`

The seed does not treat source research as production transaction authority. Every research-derived statutory parking row has `auto_application_allowed = false`.

## Seed Data

Seed scripts are separated into:

- canonical regions and provinces
- canonical LGUs
- metropolitan areas and membership
- statutory parking policy research mappings
- disabled synthetic Site Groups and Sites

Seed replay is idempotent and uses deterministic identifiers derived from stable codes.

## Metropolitan Membership

The seed includes:

- 17 Metro Manila LGUs
- 13 Expanded Metro Cebu LGUs
- 15 Metropolitan Davao LGUs

The seed also includes additional policy-referenced LGUs for Antipolo, Taytay, Malolos, Marilao, and Santa Rosa. These additional LGUs do not imply current PPG operations.

## Synthetic Sample Data

Three disabled synthetic Site Groups are seeded:

- `SAMPLE-METRO-MANILA`
- `SAMPLE-METRO-CEBU`
- `SAMPLE-METRO-DAVAO`

Exactly two disabled synthetic Sites are seeded for each metropolitan LGU. The total expected sample Site count is 90.

Synthetic sample data is non-production. Public lookup and default payment are disabled, and no POS, lane, payment, fiscal, merchant, or external-adapter configuration is created.

## Parañaque Representation

Parañaque Senior Citizen and PWD rows remain separate entitlement mappings.

Senior Citizen:

- verification: `VERIFIED_ACTIVE_OPERATIONAL`
- coverage: available
- residency: resident-only
- benefit: full parking-fee exemption
- ordinance reference: null
- source document availability: unavailable
- automatic application: false

PWD:

- verification: `VERIFIED_ACTIVE_OPERATIONAL`
- coverage: available
- residency: resident-only
- benefit: full parking-fee exemption
- ordinance reference: `City Ordinance No. 48`
- automatic application: false

The unavailable Senior Citizen ordinance number and online text remain source-document gaps, not eligibility-existence gaps.

## Non-Active Examples

The research seed preserves non-active or non-production classifications:

- Mandaue PWD remains `PROPOSED` and unavailable for coverage.
- Tagum Senior Citizen and PWD remain `LEAD_UNVERIFIED`.
- Malolos remains limited or unresolved in scope and is not citywide covered.
- `NO_LOCAL_RULE_FOUND` rows remain unavailable and not automatically applicable.

## Compatibility

Existing runtime compatibility fields remain in place:

- `sites.sites.city`
- `sites.sites.province`
- `sites.sites.lgu_code`
- `discounts.discount_policy_references.lgu_code`
- `discounts.discount_policy_references.jurisdiction_name`

The new LGU foreign keys are the canonical authority for new coverage resolution. Legacy text fields remain compatibility projections until a separate retirement task is approved.

## Production Restrictions

This seed establishes canonical reference structure and controlled research mapping only. It does not authorize production automatic application, controlled UAT, WebPay consumption, APT consumption, or benefit-effect calculation.

Production automation remains blocked until runtime tasks explicitly authorize transaction use against approved policy records.

## Validation Summary

Validation covers generated-DDL regeneration, source-layout checks, disposable PostgreSQL rebuild, seed replay, upgrade from `origin/develop`, query proofs, and guarded persistent development apply.

The persistent development apply is additive only and must not enable public lookup, payment, or statutory automatic application for synthetic data.
