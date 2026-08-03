# I-007 Canonical Mapping and Transformation Specification

## Decision

No stale table may be loaded into a canonical target without a deterministic mapping, validation query, rollback implication, and owner approval. ID preservation is preferred for durable operational records when canonical primary-key types and semantics match. ID remapping is allowed only with a durable crosswalk table stored as a migration artifact and included in validation outputs.

## Canonical Target Baseline

Future migration must start from current source-controlled generated DDL and canonical seeds, including I-006:

- `sites.philippine_regions`
- `sites.philippine_provinces`
- `sites.jurisdictions`
- `sites.metropolitan_areas`
- `sites.metropolitan_area_jurisdictions`
- `sites.site_jurisdiction_assignments`
- `sites.site_group_lgu_scopes`
- `discounts.statutory_discount_policy_registry_lgu_scopes`
- `discounts.statutory_parking_lgu_policy_coverage`
- `discounts.statutory_parking_site_policy_coverage`

## Mapping Principles

- Source database remains read-only during extraction.
- Canonical seeds load before retained data.
- Site Group is not legal ordinance authority.
- Site jurisdiction authority comes from Site-to-LGU assignment.
- Existing `sites.sites.city`, `sites.sites.province`, and `sites.sites.lgu_code` are compatibility facts, not sufficient authority.
- Monetary amounts must preserve currency, minor-unit semantics, and semantic hashes where present.
- Status codes must map through controlled-code tables or explicit mapping lists.
- Unknown controlled codes fail the migration stage.
- Null foreign keys invalid in the canonical schema must be remediated or archived.
- Duplicate natural keys require owner decision; do not choose an arbitrary winner.
- Operational event/outbox rows are archive-only unless replay is separately authorized.

## Core Operational Mapping

| Source | Target | Key rule | Required transform | Blocker |
|---|---|---|---|---|
| `core.parking_sessions` | `core.parking_sessions` | preserve `parking_session_id` if canonical-compatible | map `site_id`, `site_group_id`, status, ticket/plate mask/hash fields | Site/LGU mapping and status-code parity |
| `core.tariff_snapshots` | `core.tariff_snapshots` | preserve `tariff_snapshot_id` | validate parking-session FK, monetary fields, active/superseded graph | monetary semantic hash and active snapshot semantics |
| `core.payment_attempts` | `core.payment_attempts` | preserve attempt ID where compatible | map provider/channel/status codes and session refs | provider model parity |
| `core.payment_confirmations` | `core.payment_confirmations` | preserve confirmation ID | map attempt FK and confirmation status | payment/fiscal reconciliation |
| `core.exit_authorizations` | `core.exit_authorizations` | preserve ID | map session/payment/gate command refs | exit/fiscal/gate consistency |
| `core.fiscal_issuance_references` | fiscal reference or archive | preserve if loaded | map payment attempt and POS fiscal reference safely | POS/fiscal owner decision |

## Statutory Mapping

| Source | Target | Key rule | Required transform | Blocker |
|---|---|---|---|---|
| `discounts.statutory_discount_validations` | canonical validation or archive | preserve if loaded | map session, tariff, entitlement, evidence posture | evidence/privacy and canonical lifecycle parity |
| `discounts.statutory_discount_decision_commands` | canonical decision-v2 table | preserve command ID and request reference | bind frozen policy authority if possible | missing canonical decision-policy authority rows |
| `operator_console.statutory_discount_service_channel_reviews` | canonical review table | preserve review linkage | map reviewer and evidence status without protected evidence bytes | reviewer identity and evidence decision |
| `discounts.statutory_discount_payable_basis_applications` | application model or archive | preserve if canonical table exists | map to application-v1 command/result model | legacy table not present in generated-DDL comparison |
| `discounts.discount_policy_references` | compatibility seed rows | rebuild | compare to source-controlled seed | no direct migration without policy owner |
| `discounts.statutory_discount_policy_registry` | I-006 research seed | rebuild | load canonical research rows | local deviations require decision |

Paranaque Senior Citizen posture must be preserved as verified active operational coverage with unavailable online ordinance text/number. Do not downgrade it to unverified or proposed.

## Site, Site Group, and Jurisdiction Mapping

| Source | Target | Rule |
|---|---|---|
| `sites.site_groups` | `sites.site_groups` | classify as retained configuration, synthetic generated development data, or archive-only before loading |
| `sites.sites` | `sites.sites` | preserve `site_id` only when Site code and Site Group are unambiguous |
| `sites.sites.city/province/lgu_code` | `sites.jurisdictions` and `sites.site_jurisdiction_assignments` | map only when official PSGC/LGU match is deterministic |
| `sites.lanes` | `sites.lanes` | load only after Site is mapped |
| `sites.device_assignments` | `sites.device_assignments` | load only after Site, lane, gate device, and service identity mapping |

Blocked cases include blank or noncanonical `lgu_code`, city text mapping to multiple LGUs, NCR LGU treated as province-bearing, Site Group spanning multiple LGUs without Site-level assignment, and stale Site code conflict with I-006 synthetic samples.

## Identity and Authorization Mapping

Identity data is blocked pending business/security decision. Do not migrate users, service identities, user roles, or credential-adjacent rows automatically. Required decisions: recreate local users versus migrate existing users; rotate service identities versus preserve identifiers; preserve historical actor IDs in archive only versus target; whether stale permissions/roles are superseded by I-002/I-006 catalog seeds.

## Event, Audit, and Log Mapping

`events.domain_events`, `events.outbox_events`, `audit.audit_events`, and `operations.operator_action_logs` are archive-first. Stale outbox rows must not be replayed during migration.

## Idempotency and Conflict Rules

Extraction manifests must include table row count, primary-key count, nullable-key count, and a safe semantic hash per table. Replays into the target must be idempotent by primary key or explicit natural key. Changed source semantics under the same migration batch ID must fail with conflict. Canonical seed rows must not be silently overwritten.
