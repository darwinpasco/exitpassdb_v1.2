# I-007 Table-By-Table Retention Matrix

## Matrix Rules

Every persistent table is assigned exactly one primary disposition. Shared fields required by I-007 apply as follows unless a row says otherwise:

- Key structure: primary key plus existing unique and foreign-key constraints observed in the stale schema.
- Date range: `empty`, `key operational range captured`, or `requires per-table extract` when no safe date range was collected.
- Canonical destination: same canonical table when present; otherwise archive or owner-approved successor.
- Transformation: deterministic mapping, controlled-code conversion, Site/Site Group/LGU mapping, status mapping, null handling, duplicate handling, orphan handling, semantic-hash/idempotency handling, and audit-history posture must be defined before execution.
- Validation method: row count, primary-key uniqueness, FK closure, controlled-code checks, semantic hashes, date ranges, and owner review where sensitive.
- Rollback implication: source archive must remain available for all non-empty operational, financial, identity, statutory, and audit tables.
- Privacy classification: broad classification only; no raw values are exposed.

## Disposition Matrix

| Table | Rows | Purpose | Date range | Disposition | Canonical destination | Transformation / blocker | Privacy class | Owner |
|---|---:|---|---|---|---|---|---|---|
| audit.audit_events | 6671 | immutable audit events | key operational range captured | ARCHIVE_ONLY | archive or audit store | migrate only if audit readback is required | internal/audit/personal possible | Security/Audit |
| audit.audit_trail_entries | 0 | audit trail | empty | EMPTY_NO_ACTION | canonical audit | none | internal | Security/Audit |
| audit.evidence_links | 0 | evidence links | empty | EMPTY_NO_ACTION | future evidence metadata | none; future evidence contract controls | sensitive personal if populated | Privacy |
| audit.security_events | 0 | security events | empty | EMPTY_NO_ACTION | canonical security audit | none | auth/security | Security |
| config.controlled_code_sets | 5 | controlled codes | requires per-table extract | REBUILD_FROM_CANONICAL_SEED | canonical seed | compare to current seed; preserve local-only codes only by decision | internal/reference | Platform |
| config.feature_flags | 0 | feature flags | empty | EMPTY_NO_ACTION | canonical config | none | internal | Platform |
| config.rate_limit_policies | 4 | rate limits | requires per-table extract | REBUILD_FROM_CANONICAL_SEED | canonical seed | rebuild approved policies | internal/security | Security |
| config.system_parameters | 0 | parameters | empty | EMPTY_NO_ACTION | canonical config | none | internal | Platform |
| config.ttl_policies | 4 | TTL policies | requires per-table extract | REBUILD_FROM_CANONICAL_SEED | canonical seed | legal/privacy retention decision required | privacy/internal | Privacy |
| core.exit_authorizations | 1672 | exit authorization state | key operational range captured | BLOCKED_PENDING_MAPPING | core.exit_authorizations | map sessions, payments, gates | operational/financial | Central PMS |
| core.fiscal_issuance_attempt_history | 0 | fiscal attempt history | empty | EMPTY_NO_ACTION | fiscal history | none | financial | POS/Fiscal |
| core.fiscal_issuance_exception_reviews | 0 | fiscal exception review | empty | EMPTY_NO_ACTION | fiscal review | none | financial | POS/Fiscal |
| core.fiscal_issuance_readback_reconciliations | 0 | fiscal readback reconciliation | empty | EMPTY_NO_ACTION | reconciliation | none | financial | Reconciliation |
| core.fiscal_issuance_references | 16 | fiscal references | requires per-table extract | BLOCKED_PENDING_MAPPING | fiscal refs or archive | map payment/POS refs; fiscal owner decision | financial | POS/Fiscal |
| core.fiscal_issuance_retry_command_preparations | 0 | fiscal retry prep | empty | EMPTY_NO_ACTION | fiscal retry | none | financial | POS/Fiscal |
| core.fiscal_issuance_retry_execution_attempts | 0 | fiscal retry attempts | empty | EMPTY_NO_ACTION | fiscal retry | none | financial | POS/Fiscal |
| core.fiscal_issuance_retry_schedule_preparations | 0 | fiscal retry schedule | empty | EMPTY_NO_ACTION | fiscal retry | none | financial | POS/Fiscal |
| core.fiscal_issuance_semantic_hash_backfill_mutation_preparations | 2 | fiscal backfill prep | requires per-table extract | ARCHIVE_ONLY | archive | preserve for audit only | financial/internal | POS/Fiscal |
| core.fiscal_issuance_semantic_hash_backfill_workflow_requests | 1 | fiscal backfill workflow | requires per-table extract | ARCHIVE_ONLY | archive | preserve for audit only | financial/internal | POS/Fiscal |
| core.fiscal_issuance_semantic_hash_recalculation_previews | 2 | fiscal hash preview | requires per-table extract | ARCHIVE_ONLY | archive | preserve for audit only | financial/internal | POS/Fiscal |
| core.parking_sessions | 3153 | parking sessions | key operational range captured | BLOCKED_PENDING_MAPPING | core.parking_sessions | map Site/Site Group/LGU and statuses | operational/personal possible | Central PMS |
| core.payment_attempts | 2577 | payment attempts | key operational range captured | BLOCKED_PENDING_MAPPING | core.payment_attempts | map sessions, provider refs, statuses | financial/personal possible | Payments |
| core.payment_confirmations | 1695 | payment confirmations | key operational range captured | BLOCKED_PENDING_MAPPING | core.payment_confirmations | map attempts and provider statuses | financial | Payments |
| core.tariff_snapshots | 3788 | tariff snapshots | key operational range captured | BLOCKED_PENDING_MAPPING | core.tariff_snapshots | preserve monetary/tariff semantics | financial | Central PMS |
| core.terminal_cash_payment_command_audits | 0 | TerminalCash audit | empty | EMPTY_NO_ACTION | terminal cash audit | none | financial | Terminal Cash |
| core.terminal_cash_payment_commands | 0 | TerminalCash commands | empty | EMPTY_NO_ACTION | terminal cash commands | none | financial | Terminal Cash |
| coupons.coupon_applications | 0 | coupon applications | empty | EMPTY_NO_ACTION | coupons | none | financial | Payments |
| coupons.coupon_rule_groups | 1 | coupon rule group | requires per-table extract | REBUILD_FROM_CANONICAL_SEED | coupon seed | owner review for local rules | internal/reference | Product |
| coupons.coupon_rules | 1 | coupon rule | requires per-table extract | REBUILD_FROM_CANONICAL_SEED | coupon seed | owner review for local rules | internal/reference | Product |
| coupons.coupons | 1 | coupon | requires per-table extract | BLOCKED_PENDING_BUSINESS_DECISION | coupon seed/archive | decide reference versus test coupon | financial/config | Product |
| discounts.discount_evidence_references | 0 | evidence refs | empty | EMPTY_NO_ACTION | future evidence metadata | none | sensitive personal if populated | Privacy |
| discounts.discount_policy_references | 2 | legacy discount policy refs | requires per-table extract | REBUILD_FROM_CANONICAL_SEED | canonical policy seed | rebuild from current source; compatibility decision | policy/internal | Discounts |
| discounts.statutory_discount_decision_commands | 26 | statutory decisions | key operational range captured | BLOCKED_PENDING_MAPPING | decision-v2 table | policy authority/evidence mapping missing | sensitive statutory | Discounts |
| discounts.statutory_discount_payable_basis_application_commands | 0 | application commands | empty | EMPTY_NO_ACTION | application-v1 commands | none | financial/statutory | Discounts |
| discounts.statutory_discount_payable_basis_applications | 420 | legacy statutory applications | requires per-table extract | BLOCKED_PENDING_MAPPING | application model or archive | current DDL comparison lacks this table | financial/statutory | Discounts |
| discounts.statutory_discount_policy_registry | 3 | policy registry | requires per-table extract | REBUILD_FROM_CANONICAL_SEED | I-006 policy seed | preserve local deviations by decision only | policy/internal | Policy |
| discounts.statutory_discount_validations | 485 | statutory validations | key operational range captured | BLOCKED_PENDING_MAPPING | validations/archive | evidence/privacy and tariff mapping required | sensitive statutory | Discounts |
| events.consumer_checkpoints | 0 | checkpoints | empty | EMPTY_NO_ACTION | events | none | internal | Platform |
| events.dead_letter_records | 0 | dead letters | empty | EMPTY_NO_ACTION | events | none | internal | Platform |
| events.domain_events | 5629 | domain events | requires per-table extract | ARCHIVE_ONLY | archive | do not replay stale events | internal/personal possible | Platform |
| events.event_publications | 0 | publications | empty | EMPTY_NO_ACTION | events | none | internal | Platform |
| events.outbox_events | 5629 | outbox events | requires per-table extract | ARCHIVE_ONLY | archive | do not replay stale outbox | internal/personal possible | Platform |
| gates.gate_authorization_consumptions | 1657 | gate consumptions | key operational range captured | BLOCKED_PENDING_MAPPING | gates | map exit auth/lane/device | operational | Gates |
| gates.gate_devices | 1762 | gate devices | requires per-table extract | BLOCKED_PENDING_MAPPING | gates | map Site/lane/service identity | config/operational | Gates |
| gates.gate_events | 5 | gate events | requires per-table extract | BLOCKED_PENDING_MAPPING | gates/archive | owner decision for low-volume history | operational | Gates |
| gates.gate_heartbeats | 0 | heartbeats | empty | EMPTY_NO_ACTION | gates | none | operational | Gates |
| identity.permissions | 89 | permissions | requires per-table extract | REBUILD_FROM_CANONICAL_SEED | RBAC seed | rebuild from current catalog | authz | Security |
| identity.role_permissions | 100 | role permissions | requires per-table extract | REBUILD_FROM_CANONICAL_SEED | RBAC seed | rebuild approved grants | authz | Security |
| identity.roles | 7 | roles | requires per-table extract | REBUILD_FROM_CANONICAL_SEED | RBAC seed | rebuild approved roles | authz | Security |
| identity.service_identities | 1776 | service identities | requires per-table extract | BLOCKED_PENDING_BUSINESS_DECISION | identity | rotate/reissue versus migrate | auth/secret-adjacent | Security |
| identity.user_roles | 7 | user roles | requires per-table extract | BLOCKED_PENDING_BUSINESS_DECISION | identity | retain grants only with approval | authz/personal | Security |
| identity.users | 700 | users | requires per-table extract | BLOCKED_PENDING_BUSINESS_DECISION | identity | recreate/anonymize/migrate decision | personal/auth | Security/Privacy |
| integration.adapter_mappings | 0 | adapter mapping | empty | EMPTY_NO_ACTION | integration | none | config | Integrations |
| integration.integration_credential_references | 0 | credential refs | empty | EMPTY_NO_ACTION | secret refs | none; no credentials copied | secret-adjacent | Security |
| integration.integration_health_records | 0 | health records | empty | EMPTY_NO_ACTION | integration | none | operational | Integrations |
| integration.vendor_endpoints | 0 | vendor endpoints | empty | EMPTY_NO_ACTION | integration | none | config/secret-adjacent | Integrations |
| integration.vendor_payment_acknowledgments | 6 | vendor payment acks | requires per-table extract | BLOCKED_PENDING_MAPPING | payments/integration | map payment/provider refs | financial | Payments |
| integration.vendor_systems | 1767 | vendor systems | requires per-table extract | BLOCKED_PENDING_MAPPING | integration | classify synthetic/config; no credentials | config/secret-adjacent | Integrations |
| merchants.merchant_site_scopes | 0 | merchant scopes | empty | EMPTY_NO_ACTION | merchants | none | financial/config | Payments |
| merchants.merchant_users | 0 | merchant users | empty | EMPTY_NO_ACTION | merchants | none | personal/auth | Payments |
| merchants.merchant_wallets | 1 | wallet | requires per-table extract | BLOCKED_PENDING_BUSINESS_DECISION | merchants | financial config owner decision | financial | Payments |
| merchants.merchants | 1 | merchant | requires per-table extract | BLOCKED_PENDING_BUSINESS_DECISION | merchants | reference versus test decision | financial/config | Payments |
| operations.incident_records | 0 | incidents | empty | EMPTY_NO_ACTION | operations | none | internal | Operations |
| operations.manual_gate_logs | 0 | manual gate logs | empty | EMPTY_NO_ACTION | operations | none | operational | Operations |
| operations.operator_action_logs | 1483 | operator actions | requires per-table extract | ARCHIVE_ONLY | archive/ops | migrate only if UI requires history | internal/personal | Operations |
| operations.override_approvals | 0 | override approvals | empty | EMPTY_NO_ACTION | operations | none | internal | Operations |
| operations.override_requests | 0 | override requests | empty | EMPTY_NO_ACTION | operations | none | internal | Operations |
| operator_console.production_policy_import_review_decisions | 0 | policy import decisions | empty | EMPTY_NO_ACTION | policy import | none | policy/internal | Policy |
| operator_console.production_policy_import_review_findings | 0 | policy import findings | empty | EMPTY_NO_ACTION | policy import | none | policy/internal | Policy |
| operator_console.production_policy_import_review_history | 0 | policy import history | empty | EMPTY_NO_ACTION | policy import | none | policy/internal | Policy |
| operator_console.production_policy_import_review_submissions | 0 | policy import submissions | empty | EMPTY_NO_ACTION | policy import | none | policy/internal | Policy |
| operator_console.statutory_discount_service_channel_reviews | 23 | statutory reviews | key operational range captured | BLOCKED_PENDING_MAPPING | review table | map decision/evidence/reviewer posture | sensitive statutory | Operator Console |
| payments.payment_provider_routing_policies | 5 | routing policies | requires per-table extract | REBUILD_FROM_CANONICAL_SEED | payment seed | rebuild approved routing only | financial/config | Payments |
| payments.payment_rails | 5 | payment rails | requires per-table extract | REBUILD_FROM_CANONICAL_SEED | payment seed | rebuild approved rails | financial/config | Payments |
| payments.provider_callbacks | 0 | provider callbacks | empty | EMPTY_NO_ACTION | payments | none | financial | Payments |
| payments.provider_outcomes | 0 | outcomes | empty | EMPTY_NO_ACTION | payments | none | financial | Payments |
| payments.provider_sessions | 0 | provider sessions | empty | EMPTY_NO_ACTION | payments | none | financial | Payments |
| payments.provider_status_queries | 0 | status queries | empty | EMPTY_NO_ACTION | payments | none | financial | Payments |
| reconciliation.mops_transaction_records | 0 | MOPS records | empty | EMPTY_NO_ACTION | reconciliation | none | financial | Reconciliation |
| reconciliation.reconciliation_exception_notes | 0 | exception notes | empty | EMPTY_NO_ACTION | reconciliation | none | financial/internal | Reconciliation |
| reconciliation.reconciliation_exception_resolution_approvals | 0 | exception approvals | empty | EMPTY_NO_ACTION | reconciliation | none | financial/internal | Reconciliation |
| reconciliation.reconciliation_exception_resolution_requests | 0 | exception requests | empty | EMPTY_NO_ACTION | reconciliation | none | financial/internal | Reconciliation |
| reconciliation.reconciliation_exception_status_history | 0 | exception history | empty | EMPTY_NO_ACTION | reconciliation | none | financial/internal | Reconciliation |
| reconciliation.reconciliation_exceptions | 0 | exceptions | empty | EMPTY_NO_ACTION | reconciliation | none | financial/internal | Reconciliation |
| reconciliation.reconciliation_items | 0 | items | empty | EMPTY_NO_ACTION | reconciliation | none | financial | Reconciliation |
| reconciliation.reconciliation_runs | 0 | runs | empty | EMPTY_NO_ACTION | reconciliation | none | financial | Reconciliation |
| reconciliation.settlement_comparison_records | 0 | settlement comparisons | empty | EMPTY_NO_ACTION | reconciliation | none | financial | Reconciliation |
| sessions.session_identifier_indexes | 0 | identifier indexes | empty | EMPTY_NO_ACTION | sessions | none | session/personal | Vendor Sessions |
| sessions.session_lookup_cache | 0 | lookup cache | empty | EMPTY_NO_ACTION | sessions | none | session/personal | Vendor Sessions |
| sessions.session_resolution_requests | 0 | resolution requests | empty | EMPTY_NO_ACTION | sessions | none | session/personal | Vendor Sessions |
| sessions.session_resolution_results | 0 | resolution results | empty | EMPTY_NO_ACTION | sessions | none | session/personal | Vendor Sessions |
| sessions.vendor_session_projection_sync_targets | 1 | sync target | requires per-table extract | REBUILD_FROM_CANONICAL_SEED | session seed | rebuild approved target | config | Vendor Sessions |
| sessions.vendor_session_projections | 19 | vendor projections | requires per-table extract | BLOCKED_PENDING_MAPPING | sessions/archive | map vendor systems/sites | session/personal | Vendor Sessions |
| sites.device_assignments | 1761 | device assignments | requires per-table extract | BLOCKED_PENDING_MAPPING | sites/gates | map Site/lane/device/service identity | config/operational | Site Ops |
| sites.lanes | 1763 | lanes | requires per-table extract | BLOCKED_PENDING_MAPPING | sites | map Site and status | config/operational | Site Ops |
| sites.site_groups | 1787 | site groups | requires per-table extract | BLOCKED_PENDING_MAPPING | sites.site_groups | classify synthetic versus retained | config/operational | Site Ops |
| sites.sites | 1787 | sites | requires per-table extract | BLOCKED_PENDING_MAPPING | sites.sites | map to canonical LGU; resolve ambiguity | config/operational | Site Ops |

## Disposition Totals

- `EMPTY_NO_ACTION`: 50 tables
- `REBUILD_FROM_CANONICAL_SEED`: 14 tables
- `ARCHIVE_ONLY`: 8 tables
- `BLOCKED_PENDING_MAPPING`: 19 tables
- `BLOCKED_PENDING_BUSINESS_DECISION`: 6 tables
- `MIGRATE_AS_IS`: 0 tables
- `MIGRATE_WITH_TRANSFORM`: 0 tables until blocked mappings are resolved
- `DISCARD_SYNTHETIC_OR_TEST`: 0 tables until synthetic proof is produced
- `BLOCKED_PENDING_DATA_QUALITY_REMEDIATION`: 0 tables initially; may be assigned after profiling

## High-Risk Tables

High-risk migration tables are `core.parking_sessions`, `core.payment_attempts`, `core.payment_confirmations`, `core.tariff_snapshots`, `core.exit_authorizations`, `core.fiscal_issuance_references`, `discounts.statutory_discount_validations`, `discounts.statutory_discount_decision_commands`, `discounts.statutory_discount_payable_basis_applications`, `operator_console.statutory_discount_service_channel_reviews`, `sites.sites`, `sites.site_groups`, `identity.users`, `identity.service_identities`, `gates.gate_devices`, and `sites.device_assignments`.
