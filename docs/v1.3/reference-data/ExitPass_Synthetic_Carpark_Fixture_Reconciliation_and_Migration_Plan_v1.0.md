# ExitPass Synthetic Carpark Fixture Reconciliation and Migration Plan v1.0

## Purpose and authority

This document is a planning artifact. It inventories pre-existing synthetic Site Group, Site, and Site-jurisdiction identities after the realistic carpark catalog merge and defines gates for later, separately approved work. It does not migrate, retire, delete, rename, reassign, activate, or repurpose an identity.

The canonical database baseline is merge commit `bc12be5a672e86582b1196dd288211d5b8a371aa` on `develop` (PR #29, regular two-parent merge of source commit `f21b362f850b715f65e530cabecfc0f167f2c06d`). The repository is hybrid:

- object-per-file declarative sources are authoritative for clean construction;
- `migrations/20260813120000_realistic_carpark_catalog_canonical_seed.sql` is the additive deployed-database path;
- `build/generated/exitpass-full-object.generated.sql` is derived review/build output;
- immutable migration history and historical transaction identities are not rewritten.

The realistic baseline contains 39 Site Groups, 46 Sites, and 46 jurisdiction assignments using 13 existing jurisdictions. PITX Level 3 is activated, and the applicable Paranaque Senior Citizen free-parking privilege is confirmed and operational. The unavailable LGU ordinance copy is a documentation gap only; it does not qualify or weaken the confirmed operational coverage.

## Method

Fixture status is established from seed provenance, introducing commits, comments, deterministic identity rules, and tracked usage. A name or UUID prefix alone is not fixture evidence. The clean canonical database was built in the isolated `ep-fixture-plan-pg` PostgreSQL container from the merged generated SQL. Read-only catalog queries then enumerated fixture rows, declared and logical references, indirect foreign-key paths, and row counts.

Exact identifiers and codes were searched at recorded commits in the canonical database, ExitPass, PoS Server, APT, Assisted Payment Terminal, Management Platform, and Discounts repositories. The last two were included because exact `7700...` fixture references were found in their current tracked sources. Historical worktrees and archived repositories were not used as implementation authority.

## Inventory result

The complete row inventories are:

- [Site Group fixtures](data/ExitPass_Synthetic_Site_Group_Fixture_Inventory_v1.0.csv): 4 clean-build rows plus one conditional overloaded `7700...` fixture.
- [Site fixtures](data/ExitPass_Synthetic_Site_Fixture_Inventory_v1.0.csv): 92 clean-build rows plus one conditional overloaded `7700...` fixture.
- [assignment fixtures](data/ExitPass_Synthetic_Site_Jurisdiction_Assignment_Inventory_v1.0.csv): 90 clean-build I-006 rows.
- [database and source dependencies](data/ExitPass_Synthetic_Carpark_Fixture_Dependent_Reference_Inventory_v1.0.csv): 23 observed/conditional/controlled-text dependency summaries and all 27 declared direct foreign-key boundaries.
- [identity reconciliation](data/ExitPass_Synthetic_to_Realistic_Identity_Reconciliation_v1.0.csv): one decision row for every inventoried fixture.
- [tracked source occurrences](data/ExitPass_Synthetic_Carpark_Fixture_Tracked_Source_Occurrence_Inventory_v1.0.csv): 145 exact tracked-file occurrence groups, commit-bound and classified.

### Identity classifications and dispositions

| Fixture family | Groups | Sites | Assignments | Classification | Planning disposition |
|---|---:|---:|---:|---|---|
| Local-development MNT | 1 | 2 | 0 | `CONTROLLED_TEST_FIXTURE` | `KEEP_FOR_TEST_SCOPE_ONLY` |
| I-006 metropolitan samples | 3 | 90 | 90 | `SYNTHETIC_NO_REALISTIC_EQUIVALENT` | `KEEP_FOR_TEST_SCOPE_ONLY` |
| Overloaded `7700...` family | 1 conditional | 1 conditional | 0 | `UNRESOLVED_IDENTITY` | `SCHEMA_OR_GOVERNANCE_DECISION_REQUIRED` |

No fixture is approved for deletion, migration, retirement, or realistic identity reassignment.

## Fixture decisions

### Local-development MNT

The MNT group `594afaf3-6f55-54be-933d-c6572f4e02ec` and its Sites `110a07ad-773f-5018-b18a-d4d78e2ae6dd` and `db5f423b-ed17-59d4-a5be-e7440aca5b21` were introduced as local-development topology in commit `674433d8`. They remain ACTIVE and own five lanes, two mock gate devices, two local policy references, two merchant scopes, and two coupon rules.

The realistic `MACTAN-NEW-TOWN` group shares an estate context but has six separately evidenced facilities and a separately governed catalog lifecycle. No source proves either generic A/B fixture Site is one of those six facilities. The candidate estate-level relationship is low confidence and is not an approved mapping. The MNT identities remain test-scoped and unchanged.

### I-006 metropolitan samples

Commit `9d861ae9` explicitly introduced three disabled sample groups, two ordinal Sites per metropolitan-member LGU, and one assignment per Site for jurisdiction-coverage proof. The current clean build contains:

- Metro Manila: 1 group, 34 Sites, 34 assignments, 17 LGU scopes;
- Metro Cebu: 1 group, 26 Sites, 26 assignments, 13 LGU scopes;
- Metropolitan Davao: 1 group, 30 Sites, 30 assignments, 15 LGU scopes.

These are geographic test constructs, not physical carparks. Sharing a jurisdiction with a realistic Site is not identity evidence. All remain test-scoped; no realistic mapping is proposed.

### Canonical Test Site and overloaded `7700...` identities

The pair `77000000-0000-0000-0000-000000000001` / `77000000-0000-0000-0000-000000000002` is absent from a clean canonical build and is created only by explicit UAT/manual/local scripts. Tracked sources assign incompatible meanings, including:

- `SANDBOX_OC_SD_PILOT_GROUP` / `SANDBOX_OC_SD_PILOT_SITE`;
- `MANUAL_TEST_OPERATOR_ACCESS_GROUP` / `MANUAL_TEST_OPERATOR_ACCESS_SITE`;
- generic Test Site defaults and UI/test contracts;
- WebPay statutory walkthrough and negative fixtures;
- HikCentral UAT/local tooling.

Because one UUID pair has multiple semantic owners, it cannot be reconciled as one entity. Current scenarios keep their fixture unchanged. Any later change must allocate owner-specific deterministic identities and migrate only the owning scenario's mutable configuration. Historical rows and retained UAT evidence remain on their original identities.

## Dependency inventory

### Observed clean-build rows

| Fixture family | Dependent object | Rows | Classification | Decision |
|---|---|---:|---|---|
| MNT | `sites.sites.site_group_id` | 2 | controlled topology | keep |
| MNT | `sites.lanes.site_id` | 5 | controlled topology | keep |
| MNT | `gates.gate_devices.site_id` | 2 | controlled topology | keep |
| MNT | `discounts.discount_policy_references.site_group_id` | 2 | local placeholder policy | keep |
| MNT | `merchants.merchant_site_scopes.site_group_id` | 2 | controlled configuration | keep |
| MNT | `coupons.coupon_rules.site_group_id` | 2 | controlled configuration | keep |
| I-006 | `sites.sites.site_group_id` | 90 | test reference data | keep |
| I-006 | `sites.site_group_lgu_scopes.site_group_id` | 45 | test reference data | keep |
| I-006 | `sites.site_jurisdiction_assignments.site_id` | 90 | test reference data | keep |
| I-006 | `discounts.statutory_parking_site_policy_coverage` | 180 | research/test projection | keep |

The clean build contains no operational sessions, payments, fiscal records, gate history, audit records, events, or reconciliation rows tied to these fixture IDs. That result applies only to the disposable clean build; deployed environments require fresh counts.

The controlled text/JSON scan found ten columns containing fixture UUID/code tokens. They are the expected Site and group code columns, I-006 coverage and LGU-scope projections, MNT lane/device/coupon/policy markers, and two local merchant codes. No opaque JSON payload or transaction text contains a fixture token in the clean build. Text matches are classified independently because substring occurrence is not proof of a foreign-key relationship.

### Declared and indirect boundaries

PostgreSQL reports 27 direct foreign-key constraints into Site Groups or Sites. They cover policy/evidence, identity scopes, Operator Console access/device/shift records, fiscal references, payable-basis commands, statutory reviews, and assignments. The read-only analyzer also emits the complete indirect foreign-key graph, including downstream payment, fiscal, gate, audit, event, evidence, and reconciliation paths.

The absence of rows in a clean build does not authorize deletion in another environment. A later environment-specific preflight must count every direct and indirect path plus controlled UUID/code references in text, JSON, source-reference, and external-reference fields.

## Tracked source dependencies

The exact occurrence inventory contains:

| Repository at inspected commit | Classified paths |
|---|---:|
| `exitpassdb_v1.2@bc12be5a...` | 13 |
| `ExitPass@ee7bc754...` | 45 |
| `ExitPass-APT@bb98ed6a...` | 42 |
| `ExitPass-Discounts@ffbcd184...` | 41 |
| `ExitPass-ManagementPlatform@5b288875...` | 4 |
| `ExitPass-PoSServer@acef5c78...` | 0 |
| `ExitPass-AssistedPaymentTerminal@872fe43f...` | 0 |

The 145 matching paths classify as 46 automated tests, 43 documentation files, 19 runtime/tool configuration files, 13 UAT/local fixture files, 9 local-development fixtures, 6 validators, 5 controlled source references, 2 authoritative seeds, and 2 generated artifacts. Immutable migrations and historical evidence remain unchanged. Runtime and tool defaults using the overloaded `7700...` pair need owner-by-owner decisions; they must not be bulk-replaced.

## Historical identity rules

Never rewrite parking-session identity, tariff snapshots, payment attempts or confirmations, fiscal issuance references, exit authorizations, gate command history, audit records, event/outbox history, reconciliation records, or transaction snapshots. A historical fixture reference is valid history, not a defect. Primary keys and canonical codes are never mutated or repurposed.

If an environment has history, preserve the old Site and group identities. Future-use prevention must use an approved lifecycle/configuration control, not a foreign-key rewrite. Any schema gap in expressing test-only or retired-for-future-use posture requires a separate governance/schema decision.

## Controlled configuration rules

Potentially migratable references are limited to explicitly owned current configuration such as feature scopes, active integration mappings, development bootstrap, test harness inputs, and current examples. Each future proposal must name:

- owner and approver;
- exact source and target identity;
- proof of target readiness and physical/business equivalence;
- all references in scope;
- downtime and dual-read requirements;
- validation and rollback;
- historical rows explicitly excluded.

Foreign-key mutability alone is not approval to reassign a reference.

## Environment strategies

### Clean future build

Keep MNT and I-006 fixtures until their owning validators and local-development workflows have approved replacements. Keep the realistic catalog additive and non-operational. The `7700...` fixtures remain excluded from clean canonical construction and may be created only by their explicit scenario seeds.

### Existing reference-only environment

Rebuild from current canonical source when the environment is disposable. For non-disposable environments, first run the read-only analyzer and prove there is no operational or historical dependency. Even with zero references, deletion requires a separate implementation and explicit environment approval; the planning label `DELETE_ONLY_IF_PROVEN_UNREFERENCED` is not currently assigned.

### Existing environment with dependent history

Retain every referenced identity indefinitely. Migrate only approved current configuration to a separately approved target. Disable future use only through governed lifecycle controls. Never rewrite transaction, audit, event, fiscal, payment, gate, or reconciliation history.

## Parking Lot Index Code 1 and PITX boundary

PITX Level 3 is activated. Its applicable Paranaque Senior Citizen free-parking privilege is confirmed and operational; the unavailable LGU ordinance copy is a documentation gap only. Parking Lot Index Code `1` is used by HikCentral test/local contracts and PITX Level 3, but it is not an identity key and does not prove that Test Site, MNT, or PITX represent the same facility.

This documentation-only reconciliation task does not configure, activate, start, or contact any HikCentral target. PITX Level 3 remains confirmed activated. Any later synthetic-reference migration involving PITX must:

1. preserve the confirmed PITX operational identity and Paranaque jurisdiction coverage;
2. prove physical and governed business identity independently of Parking Lot Index Code `1`;
3. inventory endpoint, credential, Vendor System, and projection-target ownership without exposing secrets;
4. migrate only explicitly approved mutable Test Site configuration;
5. preserve all Test Site history;
6. complete isolated validation and controlled authorization for the exact reference change.

## Migration waves

### Wave 0: Preserve and freeze

Retain all identities. Add reporting and regression detection. Reject new production-facing references to test-only fixtures. No data mutation.

### Wave 1: Test-scope isolation

Confirm owners for MNT, I-006, and each overloaded `7700...` scenario. Constrain test fixtures to development/test/controlled UAT. Prove public lookup, payment, fiscal issuance, exit authorization, and production integration cannot select them.

### Wave 2: Controlled configuration reconciliation

Allocate scenario-specific fixture IDs where the `7700...` pair is overloaded. Migrate only approved mutable configuration to evidence-backed targets. Use transactional, fail-closed changes with pre/post counts and rollback. Do not touch history.

### Wave 3: Future-use retirement

Where approved, remove fixtures from future selection while retaining identities and history. This requires a supported lifecycle mechanism and owner acceptance. Referenced identities remain.

### Wave 4: Conditional cleanup

Consider deletion only in an explicitly named environment after the complete analyzer proves zero direct, indirect, textual, JSON, external-reference, and source-reference dependencies. Stop on any unclassified dependency. Obtain explicit approval immediately before deletion. No fixture currently has deletion approval.

## Validation gates for later implementation

1. Target environment is explicitly named and non-production.
2. Current canonical commit and schema are pinned.
3. Every fixture has exactly one owner, classification, and disposition.
4. Every source occurrence and database dependency is classified.
5. Realistic identity equivalence is supported by physical and business evidence.
6. Historical and audit rows are immutable.
7. Test Site scenario owners approve new scenario-specific identities.
8. PITX activation remains unchanged and outside this documentation-only migration plan; any identity mapping still requires separate evidence and approval.
9. Pre/post row counts, hashes, foreign keys, events, and configuration are reproducible.
10. Rollback restores configuration without reverting historical facts.
11. Negative tests reject omitted fixtures, unclassified dependencies, nonexistent/multiple mappings, rewritable history, referenced deletion, missing Test Site disposition, operational activation changes, and write SQL.
12. A separate change approval authorizes the exact implementation wave.

## Rollback requirements

Wave 0 reporting is source-revertible. Later configuration changes require a forward and reverse mapping manifest, before-state hashes, transactional application, and verification that the original identity remains valid. A rollback never rewrites newly created history back to another Site; it changes only current controlled configuration after event-boundary review. Partial failure preserves both identities and reconciliation evidence.

Deletion has no generic rollback. It is therefore permitted only for a conclusively unreferenced fixture in an explicitly disposable or approved reference-only environment, with an archived manifest and environment-specific approval.

## Approvals and residual risks

Required approvals include product data governance, each fixture owner, database change authority, security/RBAC owners for scoped grants, integration owners for mappings, and operations for environment-specific execution. The confirmed PITX activation and operational statutory coverage are not reopened by this plan. A future synthetic-reference migration involving PITX requires explicit identity evidence and approval for that reference change.

Residual risks:

- the `7700...` pair remains semantically overloaded across repositories;
- local APT checkout was 49 commits behind its remote tracking branch when inspected, so later implementation must rescan its then-current authoritative commit;
- clean-build zero counts do not describe deployed history;
- MNT and realistic Mactan New Town overlap at estate level without facility-level equivalence;
- some logical UUID/code references are not enforced by foreign keys;
- schemas may need an explicit non-production/test-only lifecycle before Wave 1 can be implemented.

## Next bounded task

Implement **Wave 0 only** after review: add read-only dependency reporting and regression enforcement that prevents new production-facing fixture references. Do not migrate configuration, change lifecycle state, alter PITX activation or statutory coverage, or delete data in that task.
