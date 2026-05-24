-- ExitPass v1.2 Reconciliation Exception Workflow Schema Proposal
-- Proposal only. Do not apply to live databases without approval.
--
-- Scope:
-- - Adds maker-checker workflow support for reconciliation exception review.
-- - Does not mutate payment, provider, confirmation, exit authorization, gate
--   consumption, audit history, domain event history, or outbox history.
-- - Does not introduce financial posting tables.
--
-- Live schema prerequisites observed before this draft:
-- - reconciliation.reconciliation_runs
-- - reconciliation.reconciliation_items
-- - reconciliation.reconciliation_exceptions
-- - audit.audit_events
-- - audit.audit_trail_entries
-- - identity.users
-- - identity.service_identities

BEGIN;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'reconciliation'
          AND t.typname = 'reconciliation_exception_note_type_enum'
    ) THEN
        CREATE TYPE reconciliation.reconciliation_exception_note_type_enum AS ENUM (
            'REVIEW_NOTE',
            'PROVIDER_CHECK_NOTE',
            'INTERNAL_CHECK_NOTE',
            'FINANCIAL_IMPACT_NOTE',
            'SYSTEM_NOTE'
        );
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'reconciliation'
          AND t.typname = 'reconciliation_resolution_action_enum'
    ) THEN
        CREATE TYPE reconciliation.reconciliation_resolution_action_enum AS ENUM (
            'RESOLVE_NO_ADJUSTMENT',
            'RESOLVE_WITH_OPERATIONAL_NOTE',
            'REQUEST_FINANCIAL_ADJUSTMENT',
            'ACCEPT_PROVIDER_EVIDENCE',
            'OVERRIDE_RECONCILIATION_STATUS',
            'REOPEN_EXCEPTION',
            'CLOSE_EXCEPTION',
            'CANCEL_EXCEPTION'
        );
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'reconciliation'
          AND t.typname = 'reconciliation_resolution_request_status_enum'
    ) THEN
        CREATE TYPE reconciliation.reconciliation_resolution_request_status_enum AS ENUM (
            'DRAFT',
            'SUBMITTED',
            'PENDING_APPROVAL',
            'APPROVED',
            'REJECTED',
            'CANCELLED',
            'SUPERSEDED'
        );
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'reconciliation'
          AND t.typname = 'reconciliation_resolution_approval_decision_enum'
    ) THEN
        CREATE TYPE reconciliation.reconciliation_resolution_approval_decision_enum AS ENUM (
            'APPROVED',
            'REJECTED'
        );
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'reconciliation'
          AND t.typname = 'reconciliation_financial_impact_enum'
    ) THEN
        CREATE TYPE reconciliation.reconciliation_financial_impact_enum AS ENUM (
            'NONE',
            'POSSIBLE',
            'DEFINITE',
            'CONTROL_ONLY'
        );
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS reconciliation.reconciliation_exception_notes (
    reconciliation_exception_note_id uuid DEFAULT gen_random_uuid() NOT NULL,
    reconciliation_exception_id uuid NOT NULL,
    reconciliation_run_id uuid NOT NULL,
    reconciliation_item_id uuid,
    note_type reconciliation.reconciliation_exception_note_type_enum NOT NULL,
    note_summary character varying(256) NOT NULL,
    note_detail text,
    detail_ref character varying(256),
    detail_hash character(64),
    audit_event_id uuid,
    audit_trail_entry_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    correlation_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT pk_reconciliation_exception_notes PRIMARY KEY (reconciliation_exception_note_id),
    CONSTRAINT ck_reconciliation_exception_notes__row_version_positive CHECK (row_version > 0),
    CONSTRAINT ck_reconciliation_exception_notes__detail_hash_length CHECK (detail_hash IS NULL OR length(detail_hash) = 64),
    CONSTRAINT fk_reconciliation_exception_notes__exception_id FOREIGN KEY (reconciliation_exception_id) REFERENCES reconciliation.reconciliation_exceptions(reconciliation_exception_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_notes__run_id FOREIGN KEY (reconciliation_run_id) REFERENCES reconciliation.reconciliation_runs(reconciliation_run_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_notes__item_id FOREIGN KEY (reconciliation_item_id) REFERENCES reconciliation.reconciliation_items(reconciliation_item_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_notes__audit_event_id FOREIGN KEY (audit_event_id) REFERENCES audit.audit_events(audit_event_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_notes__audit_trail_entry_id FOREIGN KEY (audit_trail_entry_id) REFERENCES audit.audit_trail_entries(audit_trail_entry_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_notes__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_notes__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE
);

CREATE TABLE IF NOT EXISTS reconciliation.reconciliation_exception_resolution_requests (
    reconciliation_exception_resolution_request_id uuid DEFAULT gen_random_uuid() NOT NULL,
    reconciliation_exception_id uuid NOT NULL,
    reconciliation_run_id uuid NOT NULL,
    reconciliation_item_id uuid,
    requested_action reconciliation.reconciliation_resolution_action_enum NOT NULL,
    request_status reconciliation.reconciliation_resolution_request_status_enum NOT NULL,
    previous_exception_status reconciliation.reconciliation_exception_status_enum NOT NULL,
    proposed_exception_status reconciliation.reconciliation_exception_status_enum NOT NULL,
    previous_item_status reconciliation.reconciliation_item_status_enum,
    proposed_item_status reconciliation.reconciliation_item_status_enum,
    previous_match_status reconciliation.reconciliation_match_status_enum,
    proposed_match_status reconciliation.reconciliation_match_status_enum,
    financial_impact reconciliation.reconciliation_financial_impact_enum NOT NULL,
    financial_impact_flag boolean DEFAULT false NOT NULL,
    adjustment_required_flag boolean DEFAULT false NOT NULL,
    amount_delta numeric,
    currency_code character(3),
    resolution_reason_code character varying(128) NOT NULL,
    rejection_reason_code character varying(128),
    request_summary character varying(256) NOT NULL,
    request_detail text,
    evidence_ref character varying(256),
    evidence_hash character(64),
    submitted_at timestamp with time zone,
    cancelled_at timestamp with time zone,
    closed_at timestamp with time zone,
    maker_user_id uuid,
    maker_service_identity_id uuid,
    audit_event_id uuid,
    audit_trail_entry_id uuid,
    correlation_id uuid,
    causation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT pk_reconciliation_exception_resolution_requests PRIMARY KEY (reconciliation_exception_resolution_request_id),
    CONSTRAINT ck_reconciliation_exception_resolution_requests__row_version_positive CHECK (row_version > 0),
    CONSTRAINT ck_reconciliation_exception_resolution_requests__amount_delta_non_negative CHECK (amount_delta IS NULL OR amount_delta >= 0),
    CONSTRAINT ck_reconciliation_exception_resolution_requests__evidence_hash_length CHECK (evidence_hash IS NULL OR length(evidence_hash) = 64),
    CONSTRAINT ck_reconciliation_exception_resolution_requests__submitted_when_not_draft CHECK (
        request_status = 'DRAFT'
        OR submitted_at IS NOT NULL
    ),
    CONSTRAINT ck_reconciliation_exception_resolution_requests__financial_flags_consistent CHECK (
        (financial_impact IN ('POSSIBLE', 'DEFINITE') AND financial_impact_flag = true)
        OR (financial_impact IN ('NONE', 'CONTROL_ONLY'))
        OR financial_impact_flag = true
    ),
    CONSTRAINT ck_reconciliation_exception_resolution_requests__adjustment_requires_financial_impact CHECK (
        adjustment_required_flag = false
        OR financial_impact IN ('POSSIBLE', 'DEFINITE')
    ),
    CONSTRAINT fk_reconciliation_exception_resolution_requests__exception_id FOREIGN KEY (reconciliation_exception_id) REFERENCES reconciliation.reconciliation_exceptions(reconciliation_exception_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_resolution_requests__run_id FOREIGN KEY (reconciliation_run_id) REFERENCES reconciliation.reconciliation_runs(reconciliation_run_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_resolution_requests__item_id FOREIGN KEY (reconciliation_item_id) REFERENCES reconciliation.reconciliation_items(reconciliation_item_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_resolution_requests__maker_user_id FOREIGN KEY (maker_user_id) REFERENCES identity.users(user_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_resolution_requests__maker_service_identity_id FOREIGN KEY (maker_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_resolution_requests__audit_event_id FOREIGN KEY (audit_event_id) REFERENCES audit.audit_events(audit_event_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_resolution_requests__audit_trail_entry_id FOREIGN KEY (audit_trail_entry_id) REFERENCES audit.audit_trail_entries(audit_trail_entry_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_resolution_requests__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_resolution_requests__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_resolution_requests__updated_by_user_id FOREIGN KEY (updated_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_resolution_requests__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE
);

CREATE TABLE IF NOT EXISTS reconciliation.reconciliation_exception_resolution_approvals (
    reconciliation_exception_resolution_approval_id uuid DEFAULT gen_random_uuid() NOT NULL,
    reconciliation_exception_resolution_request_id uuid NOT NULL,
    reconciliation_exception_id uuid NOT NULL,
    reconciliation_run_id uuid NOT NULL,
    reconciliation_item_id uuid,
    approval_decision reconciliation.reconciliation_resolution_approval_decision_enum NOT NULL,
    approval_reason_code character varying(128),
    rejection_reason_code character varying(128),
    approval_summary character varying(256) NOT NULL,
    approval_detail text,
    approved_at timestamp with time zone,
    rejected_at timestamp with time zone,
    checker_user_id uuid,
    checker_service_identity_id uuid,
    maker_user_id uuid,
    maker_service_identity_id uuid,
    audit_event_id uuid,
    audit_trail_entry_id uuid,
    correlation_id uuid,
    causation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT pk_reconciliation_exception_resolution_approvals PRIMARY KEY (reconciliation_exception_resolution_approval_id),
    CONSTRAINT ck_reconciliation_exception_resolution_approvals__row_version_positive CHECK (row_version > 0),
    CONSTRAINT ck_reconciliation_exception_resolution_approvals__decision_timestamp CHECK (
        (approval_decision = 'APPROVED' AND approved_at IS NOT NULL AND rejected_at IS NULL)
        OR
        (approval_decision = 'REJECTED' AND rejected_at IS NOT NULL AND approved_at IS NULL)
    ),
    CONSTRAINT ck_reconciliation_exception_resolution_approvals__rejection_reason CHECK (
        approval_decision = 'APPROVED'
        OR rejection_reason_code IS NOT NULL
    ),
    CONSTRAINT ck_reconciliation_exception_resolution_approvals__maker_checker_user_separation CHECK (
        maker_user_id IS NULL
        OR checker_user_id IS NULL
        OR maker_user_id <> checker_user_id
    ),
    CONSTRAINT ck_reconciliation_exception_resolution_approvals__maker_checker_service_separation CHECK (
        maker_service_identity_id IS NULL
        OR checker_service_identity_id IS NULL
        OR maker_service_identity_id <> checker_service_identity_id
    ),
    CONSTRAINT fk_reconciliation_exception_resolution_approvals__request_id FOREIGN KEY (reconciliation_exception_resolution_request_id) REFERENCES reconciliation.reconciliation_exception_resolution_requests(reconciliation_exception_resolution_request_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_resolution_approvals__exception_id FOREIGN KEY (reconciliation_exception_id) REFERENCES reconciliation.reconciliation_exceptions(reconciliation_exception_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_resolution_approvals__run_id FOREIGN KEY (reconciliation_run_id) REFERENCES reconciliation.reconciliation_runs(reconciliation_run_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_resolution_approvals__item_id FOREIGN KEY (reconciliation_item_id) REFERENCES reconciliation.reconciliation_items(reconciliation_item_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_resolution_approvals__checker_user_id FOREIGN KEY (checker_user_id) REFERENCES identity.users(user_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_resolution_approvals__checker_service_identity_id FOREIGN KEY (checker_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_resolution_approvals__maker_user_id FOREIGN KEY (maker_user_id) REFERENCES identity.users(user_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_resolution_approvals__maker_service_identity_id FOREIGN KEY (maker_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_resolution_approvals__audit_event_id FOREIGN KEY (audit_event_id) REFERENCES audit.audit_events(audit_event_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_resolution_approvals__audit_trail_entry_id FOREIGN KEY (audit_trail_entry_id) REFERENCES audit.audit_trail_entries(audit_trail_entry_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_resolution_approvals__created_by_user_id FOREIGN KEY (created_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_resolution_approvals__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE
);

CREATE TABLE IF NOT EXISTS reconciliation.reconciliation_exception_status_history (
    reconciliation_exception_status_history_id uuid DEFAULT gen_random_uuid() NOT NULL,
    reconciliation_exception_id uuid NOT NULL,
    reconciliation_run_id uuid NOT NULL,
    reconciliation_item_id uuid,
    reconciliation_exception_resolution_request_id uuid,
    reconciliation_exception_resolution_approval_id uuid,
    previous_exception_status reconciliation.reconciliation_exception_status_enum,
    new_exception_status reconciliation.reconciliation_exception_status_enum NOT NULL,
    previous_item_status reconciliation.reconciliation_item_status_enum,
    new_item_status reconciliation.reconciliation_item_status_enum,
    reason_code character varying(128) NOT NULL,
    transition_summary character varying(256) NOT NULL,
    transition_detail text,
    changed_at timestamp with time zone NOT NULL,
    changed_by_user_id uuid,
    changed_by_service_identity_id uuid,
    audit_event_id uuid,
    audit_trail_entry_id uuid,
    correlation_id uuid,
    causation_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT pk_reconciliation_exception_status_history PRIMARY KEY (reconciliation_exception_status_history_id),
    CONSTRAINT ck_reconciliation_exception_status_history__row_version_positive CHECK (row_version > 0),
    CONSTRAINT ck_reconciliation_exception_status_history__status_changed CHECK (
        previous_exception_status IS NULL
        OR previous_exception_status <> new_exception_status
    ),
    CONSTRAINT fk_reconciliation_exception_status_history__exception_id FOREIGN KEY (reconciliation_exception_id) REFERENCES reconciliation.reconciliation_exceptions(reconciliation_exception_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_status_history__run_id FOREIGN KEY (reconciliation_run_id) REFERENCES reconciliation.reconciliation_runs(reconciliation_run_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_status_history__item_id FOREIGN KEY (reconciliation_item_id) REFERENCES reconciliation.reconciliation_items(reconciliation_item_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_status_history__request_id FOREIGN KEY (reconciliation_exception_resolution_request_id) REFERENCES reconciliation.reconciliation_exception_resolution_requests(reconciliation_exception_resolution_request_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_status_history__approval_id FOREIGN KEY (reconciliation_exception_resolution_approval_id) REFERENCES reconciliation.reconciliation_exception_resolution_approvals(reconciliation_exception_resolution_approval_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_status_history__changed_by_user_id FOREIGN KEY (changed_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_status_history__changed_by_service_identity_id FOREIGN KEY (changed_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_status_history__audit_event_id FOREIGN KEY (audit_event_id) REFERENCES audit.audit_events(audit_event_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_status_history__audit_trail_entry_id FOREIGN KEY (audit_trail_entry_id) REFERENCES audit.audit_trail_entries(audit_trail_entry_id) DEFERRABLE,
    CONSTRAINT fk_reconciliation_exception_status_history__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id) REFERENCES identity.service_identities(service_identity_id) DEFERRABLE
);

CREATE INDEX IF NOT EXISTS ix_reconciliation_exception_notes__exception_id
    ON reconciliation.reconciliation_exception_notes (reconciliation_exception_id);

CREATE INDEX IF NOT EXISTS ix_reconciliation_exception_notes__run_id
    ON reconciliation.reconciliation_exception_notes (reconciliation_run_id);

CREATE INDEX IF NOT EXISTS ix_reconciliation_exception_notes__created_at
    ON reconciliation.reconciliation_exception_notes (created_at);

CREATE INDEX IF NOT EXISTS ix_reconciliation_exception_notes__correlation_id
    ON reconciliation.reconciliation_exception_notes (correlation_id)
    WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_reconciliation_exception_resolution_requests__exception_id
    ON reconciliation.reconciliation_exception_resolution_requests (reconciliation_exception_id);

CREATE INDEX IF NOT EXISTS ix_reconciliation_exception_resolution_requests__run_id
    ON reconciliation.reconciliation_exception_resolution_requests (reconciliation_run_id);

CREATE INDEX IF NOT EXISTS ix_reconciliation_exception_resolution_requests__request_status
    ON reconciliation.reconciliation_exception_resolution_requests (request_status);

CREATE INDEX IF NOT EXISTS ix_reconciliation_exception_resolution_requests__submitted_at
    ON reconciliation.reconciliation_exception_resolution_requests (submitted_at)
    WHERE submitted_at IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_reconciliation_exception_resolution_requests__correlation_id
    ON reconciliation.reconciliation_exception_resolution_requests (correlation_id)
    WHERE correlation_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_reconciliation_exception_resolution_requests__active_exception
    ON reconciliation.reconciliation_exception_resolution_requests (reconciliation_exception_id)
    WHERE request_status IN ('SUBMITTED', 'PENDING_APPROVAL');

CREATE INDEX IF NOT EXISTS ix_reconciliation_exception_resolution_approvals__exception_id
    ON reconciliation.reconciliation_exception_resolution_approvals (reconciliation_exception_id);

CREATE INDEX IF NOT EXISTS ix_reconciliation_exception_resolution_approvals__run_id
    ON reconciliation.reconciliation_exception_resolution_approvals (reconciliation_run_id);

CREATE INDEX IF NOT EXISTS ix_reconciliation_exception_resolution_approvals__decision
    ON reconciliation.reconciliation_exception_resolution_approvals (approval_decision);

CREATE INDEX IF NOT EXISTS ix_reconciliation_exception_resolution_approvals__correlation_id
    ON reconciliation.reconciliation_exception_resolution_approvals (correlation_id)
    WHERE correlation_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_reconciliation_exception_resolution_approvals__request_id
    ON reconciliation.reconciliation_exception_resolution_approvals (reconciliation_exception_resolution_request_id);

CREATE INDEX IF NOT EXISTS ix_reconciliation_exception_status_history__exception_id
    ON reconciliation.reconciliation_exception_status_history (reconciliation_exception_id);

CREATE INDEX IF NOT EXISTS ix_reconciliation_exception_status_history__run_id
    ON reconciliation.reconciliation_exception_status_history (reconciliation_run_id);

CREATE INDEX IF NOT EXISTS ix_reconciliation_exception_status_history__changed_at
    ON reconciliation.reconciliation_exception_status_history (changed_at);

CREATE INDEX IF NOT EXISTS ix_reconciliation_exception_status_history__correlation_id
    ON reconciliation.reconciliation_exception_status_history (correlation_id)
    WHERE correlation_id IS NOT NULL;

COMMIT;
