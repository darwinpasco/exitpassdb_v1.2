# Reconciliation Exception Workflow Schema Proposal v1.2

Status: proposal only  
Repository: `ExitPass_DBv1.2`  
Branch: `design/reconciliation-exception-workflow-schema-proposal`  
Date: 2026-05-24

This proposal defines database objects for a future maker-checker reconciliation exception workflow. It is not an applied migration and must not be executed against live databases without an approved implementation slice.

## Scope

In scope:

- Review notes for reconciliation exceptions.
- Resolution requests submitted by a maker/reviewer.
- Approval or rejection by a checker/approver.
- Status transition history.
- Audit traceability through existing `audit.audit_events` and `audit.audit_trail_entries`.

Out of scope:

- App code.
- Live database mutation.
- Payment finality mutation.
- Provider session mutation.
- Payment confirmation mutation.
- Exit authorization mutation.
- Gate consumption mutation.
- Financial posting, payout, or settlement processing.

The PayMongo WebPay QRPH/PHP reconciliation assumption remains PAYMONGO-only.

## Live Schema Inspection

The live PostgreSQL database `exitpass_v12_dev` was inspected through catalog queries before drafting this proposal.

### Existing Reconciliation Tables

`reconciliation.reconciliation_runs` already provides:

- `reconciliation_run_id`
- `run_code`
- `run_type`
- `run_status`
- `scope_type`
- `source_batch_ref`
- `window_start_at`, `window_end_at`
- `item_count`, `matched_count`, `exception_count`, `rejected_count`, `disputed_count`
- initiated/created/updated identity fields
- `correlation_id`
- `row_version`

`reconciliation.reconciliation_items` already provides:

- `reconciliation_item_id`
- `reconciliation_run_id`
- `payment_attempt_id`
- `payment_confirmation_id`
- `provider_outcome_id`
- `target_entity_type`, `target_entity_id`
- `comparison_basis`
- `item_status`
- `match_status`
- expected/actual amount and variance fields
- `exception_reason_code`
- `resolved_at`, resolved identity fields
- created/updated identity fields
- `correlation_id`
- `row_version`

`reconciliation.reconciliation_exceptions` already provides:

- `reconciliation_exception_id`
- `reconciliation_run_id`
- `reconciliation_item_id`
- `incident_record_id`
- `exception_type`
- `exception_severity`
- `exception_status`
- `exception_reason_code`
- `exception_summary`
- `exception_detail`
- assignment fields
- `resolved_at`, `resolution_reason_code`, resolved identity fields
- `closed_at`, `closure_reason_code`, closed identity fields
- created/updated identity fields
- `correlation_id`
- `row_version`

The current exception table supports basic assignment, review, resolution, rejection, escalation, closure, and cancellation. It does not store immutable notes, resolution recommendations, approval decisions, maker-checker separation, or full status history.

### Relevant Existing Enums

Existing reconciliation enums include:

- `reconciliation_exception_status_enum`: `OPEN`, `ASSIGNED`, `UNDER_REVIEW`, `RESOLVED`, `REJECTED`, `ESCALATED`, `CLOSED`, `CANCELLED`.
- `reconciliation_exception_severity_enum`: `LOW`, `MEDIUM`, `HIGH`, `CRITICAL`.
- `reconciliation_exception_type_enum`: `AMOUNT_MISMATCH`, `MISSING_PAYMENT_CONFIRMATION`, `MISSING_PROVIDER_OUTCOME`, `MISSING_MOPS_RECORD`, `DUPLICATE_RECORD`, `MANUAL_GATE_WITHOUT_PAYMENT`, `SETTLEMENT_MISMATCH`, `COUPON_WALLET_MISMATCH`, `UNRESOLVED_CONTINUITY_RECORD`, `POLICY_EXCEPTION`, `UNKNOWN_EXCEPTION`.
- `reconciliation_item_status_enum`: `PENDING`, `MATCHED`, `MISMATCHED`, `EXCEPTION`, `DISPUTED`, `REJECTED`, `RESOLVED`, `CLOSED`.
- `reconciliation_match_status_enum`: `NOT_EVALUATED`, `MATCH`, `AMOUNT_MISMATCH`, `MISSING_SOURCE`, `MISSING_TARGET`, `DUPLICATE`, `INCONCLUSIVE`, `REJECTED`.

### Existing Audit and Event Tables

`audit.audit_events` supports high-level immutable audit records with:

- event type/category/result/reason
- target and related entity references
- source schema/service/channel
- actor user or service identity
- summary and details references/hashes
- occurred/recorded timestamps
- correlation and causation ids

`audit.audit_trail_entries` supports field-level change evidence with:

- change type
- target entity and field name
- before/after redacted values or hashes
- reason code and summary
- actor identity
- `approval_reference_type`
- `approval_reference_id`
- correlation id

`events.domain_events` and `events.outbox_events` exist for domain/outbox eventing. They should remain best-effort integration evidence and not become required for exception workflow persistence.

### Identity and Approval Patterns

`identity.users`, `identity.roles`, `identity.permissions`, `identity.user_roles`, and `identity.role_permissions` exist and support RBAC. `identity.roles.requires_elevated_approval` is present.

Catalog search found:

- `audit.audit_trail_entries`
- `operations.override_approvals`
- `sessions.session_resolution_requests`
- `sessions.session_resolution_results`

There is no reconciliation-specific maker-checker approval table in the live schema. The proposal therefore adds reconciliation-owned workflow tables rather than reusing `operations.override_approvals`.

## Proposed Objects

Proposal SQL:

- `proposals/ExitPass_Reconciliation_Exception_Workflow_Proposal_v1.2.sql`

Rollback draft:

- `proposals/ExitPass_Reconciliation_Exception_Workflow_Proposal_v1.2_rollback.sql`

### Proposed Enums

`reconciliation.reconciliation_exception_note_type_enum`

- `REVIEW_NOTE`
- `PROVIDER_CHECK_NOTE`
- `INTERNAL_CHECK_NOTE`
- `FINANCIAL_IMPACT_NOTE`
- `SYSTEM_NOTE`

`reconciliation.reconciliation_resolution_action_enum`

- `RESOLVE_NO_ADJUSTMENT`
- `RESOLVE_WITH_OPERATIONAL_NOTE`
- `REQUEST_FINANCIAL_ADJUSTMENT`
- `ACCEPT_PROVIDER_EVIDENCE`
- `OVERRIDE_RECONCILIATION_STATUS`
- `REOPEN_EXCEPTION`
- `CLOSE_EXCEPTION`
- `CANCEL_EXCEPTION`

`reconciliation.reconciliation_resolution_request_status_enum`

- `DRAFT`
- `SUBMITTED`
- `PENDING_APPROVAL`
- `APPROVED`
- `REJECTED`
- `CANCELLED`
- `SUPERSEDED`

`reconciliation.reconciliation_resolution_approval_decision_enum`

- `APPROVED`
- `REJECTED`

`reconciliation.reconciliation_financial_impact_enum`

- `NONE`
- `POSSIBLE`
- `DEFINITE`
- `CONTROL_ONLY`

### Proposed Tables

#### `reconciliation.reconciliation_exception_notes`

Purpose: immutable notes and investigation records. Pure notes do not require checker approval.

Key fields:

- note id
- exception id
- run id
- item id
- note type
- summary/detail or detail reference/hash
- audit event and audit trail entry linkage
- actor identity fields
- correlation id
- row version

#### `reconciliation.reconciliation_exception_resolution_requests`

Purpose: maker-submitted recommendation for exception resolution.

Key fields:

- request id
- exception/run/item ids
- requested action
- request status
- previous and proposed exception status
- previous and proposed item/match status
- financial impact classification
- financial impact flag
- adjustment required flag
- amount delta and currency when applicable
- resolution/rejection reason fields
- evidence reference/hash
- submitted/cancelled/closed timestamps
- maker identity fields
- audit event and audit trail entry linkage
- correlation and causation ids
- row version

Control:

- One active submitted/pending request per exception through a partial unique index.
- Adjustment-required requests must carry possible or definite financial impact.
- Non-draft requests must have `submitted_at`.

#### `reconciliation.reconciliation_exception_resolution_approvals`

Purpose: checker approval or rejection for a submitted resolution request.

Key fields:

- approval id
- resolution request id
- exception/run/item ids
- decision
- approval or rejection reason
- approved/rejected timestamp
- checker identity fields
- maker identity snapshot
- audit event and audit trail entry linkage
- correlation and causation ids
- row version

Control:

- One approval decision per resolution request.
- Approval and rejection timestamps are mutually exclusive.
- Rejection requires a rejection reason.
- Maker and checker must be different users when both are user identities.
- Maker and checker must be different service identities when both are service identities.

#### `reconciliation.reconciliation_exception_status_history`

Purpose: immutable transition history.

Key fields:

- history id
- exception/run/item ids
- optional resolution request and approval ids
- previous/new exception status
- previous/new item status
- reason code
- summary/detail
- actor identity
- changed timestamp
- audit event and audit trail entry linkage
- correlation and causation ids
- row version

Control:

- Status history is append-only by application convention.
- Records every workflow transition, including assignment, under review, recommendation submitted, approved, rejected, resolved, closed, cancelled, and reopened.

## Relationship Notes

Relationship outline:

- `reconciliation_exception_notes` many-to-one `reconciliation_exceptions`
- `reconciliation_exception_resolution_requests` many-to-one `reconciliation_exceptions`
- `reconciliation_exception_resolution_approvals` one-to-one `reconciliation_exception_resolution_requests`
- `reconciliation_exception_status_history` many-to-one `reconciliation_exceptions`
- all workflow tables link to `reconciliation_runs`
- all workflow tables optionally link to `reconciliation_items`
- all workflow tables optionally link to `audit.audit_events`
- all workflow tables optionally link to `audit.audit_trail_entries`
- actor fields reference `identity.users` and/or `identity.service_identities`

## Control Rules

The schema is designed to support these controls:

- Exception resolution does not directly mutate historical payment truth.
- Financial-impact resolutions require maker-checker approval.
- Pure review notes do not require checker approval.
- Reopening a closed exception requires a resolution request and checker approval.
- Status changes are traceable through status history and audit trail rows.
- Resolution requests are versioned records, not in-place-only state.
- Approval decisions are separate from maker recommendations.

The database proposal does not by itself enforce every business rule. Application code and stored procedures in a later implementation slice must enforce:

- role authorization
- maker/checker role separation
- allowed state transitions
- which classifications require approval
- audit-event creation in the same transaction as workflow mutation
- concurrency checks using row version

## Non-Mutation Boundary

Future workflow code must not directly mutate:

- `core.payment_attempts`
- `payments.provider_sessions`
- `core.payment_confirmations`
- `core.exit_authorizations`
- `gates.gate_authorization_consumptions`
- historical audit rows
- historical domain event rows
- historical outbox rows

Corrections must be represented through reconciliation workflow records and future approved financial or operational commands. Financial posting remains separate.

## Validation Plan

Completed for this proposal:

- Live schema inspected first.
- Proposal SQL generated only.
- Rollback draft generated.
- No proposal SQL was executed against the live database.
- No live data was mutated.

Recommended before approval:

- Apply proposal to a disposable database copy.
- Run `pg_dump --schema-only` on the disposable database and inspect object order.
- Verify FK and partial unique index behavior.
- Verify rollback removes only proposed objects.
- Review naming with database maintainers.
- Review RBAC permissions to add in a separate reference-data or identity migration.

## Open Decisions

- Whether to extend existing `reconciliation_exception_status_enum` or keep detailed workflow states in request/status-history tables.
- Whether notes should allow inline `note_detail` or require detail references and hashes only.
- Whether approval decisions must support multi-level approvals for critical exceptions.
- Whether maker/checker separation should also reject users who share the same privileged role assignment chain.
- Whether future workflow mutation should be implemented only through stored procedures.
- Whether workflow domain/outbox events should be written synchronously as part of the same transaction or best-effort after audit persistence.
