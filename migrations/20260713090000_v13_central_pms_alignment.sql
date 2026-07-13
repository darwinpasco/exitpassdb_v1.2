-- ExitPass v1.3 Central PMS DB alignment.
-- Additive alignment migration for the canonical exitpassdb_v1.2 repository.
-- This migration promotes approved Central PMS v1.3 persistence objects from the
-- ExitPass application repository without removing or weakening v1.2 baseline objects.
-- Non-goals: POS Server-owned pos.* fiscal document tables, payment provider calls,
-- HikCentral calls, gate/ExitAuthorization behavior, refunds/reversals, and rendered
-- final BIR artifacts.


-- ============================================================================
-- Promoted source patch: D:\SourceCodes\ExitPass\infra\db\patches\ExitPass_CentralPms_FiscalReferenceStatePersistence_v1.3.sql
-- ============================================================================

-- ExitPass v1.3 Central PMS fiscal reference state persistence scaffolding.
--
-- Scope:
-- - Persistence/state only for Central PMS fiscal issuance reference evidence.
-- - No POS Server network behavior, retry worker, readback worker, ExitAuthorization gating,
--   Operator Console queue, Dashboard projection, Digital SI, X/Z, BIR, EJ, POSLog, or gate behavior.

CREATE TABLE IF NOT EXISTS core.fiscal_issuance_references (
    fiscal_issuance_reference_id uuid DEFAULT gen_random_uuid() NOT NULL,
    payment_confirmation_id uuid NOT NULL,
    payment_attempt_id uuid NOT NULL,
    parking_session_id uuid NOT NULL,
    tariff_snapshot_id uuid,
    site_id uuid,
    site_pos_server_id uuid,
    site_pos_server_ref varchar(128),
    fiscal_document_type_code_id uuid,
    fiscal_document_type_code_key varchar(80),
    payable_basis_ref varchar(160),
    upstream_finality_reference varchar(200) NOT NULL,
    pos_server_fiscal_document_id uuid,
    fiscal_identity_id uuid,
    fiscal_sequence_policy_id uuid,
    fiscal_sequence_value bigint,
    fiscal_document_number varchar(120),
    fiscal_series varchar(80),
    fiscal_number_prefix_text varchar(80),
    fiscal_number_suffix_text varchar(80),
    fiscal_number_assigned_at timestamptz,
    fiscal_number_assigned_by_ref varchar(160),
    fiscal_document_status_code_id uuid,
    result_classification varchar(40),
    fiscal_issuance_evidence_status varchar(80),
    fiscal_number_assignment_state varchar(40) DEFAULT 'NOT_ASSIGNED' NOT NULL,
    fiscal_issuance_state varchar(80) NOT NULL,
    latest_exception_reason varchar(120),
    latest_error_code varchar(120),
    latest_error_posture varchar(80),
    correlation_id uuid,
    pos_server_response_timestamp timestamptz,
    semantic_request_hash_status varchar(40),
    semantic_request_hash_value varchar(64),
    semantic_request_hash_algorithm varchar(32),
    semantic_request_hash_source_version varchar(80),
    semantic_request_hash_source_fact_count integer,
    semantic_request_hash_safe_summary varchar(240),
    semantic_request_hash_recorded_at timestamptz,
    first_recorded_at timestamptz DEFAULT now() NOT NULL,
    last_updated_at timestamptz DEFAULT now() NOT NULL,
    recorded_by_service_identity_id uuid,
    updated_by_service_identity_id uuid,
    is_active boolean DEFAULT true NOT NULL,
    is_superseded boolean DEFAULT false NOT NULL,
    is_reconciled boolean DEFAULT false NOT NULL,
    CONSTRAINT pk_fiscal_issuance_references PRIMARY KEY (fiscal_issuance_reference_id),
    CONSTRAINT ck_fiscal_issuance_references__fiscal_sequence_value_positive CHECK (fiscal_sequence_value IS NULL OR fiscal_sequence_value > 0),
    CONSTRAINT ck_fiscal_issuance_references__result_classification CHECK (
        result_classification IS NULL
        OR result_classification IN ('NEWLY_CREATED', 'IDEMPOTENT_REPLAY')
    ),
    CONSTRAINT ck_fiscal_issuance_references__evidence_status CHECK (
        fiscal_issuance_evidence_status IS NULL
        OR fiscal_issuance_evidence_status IN ('FISCAL_DOCUMENT_NUMBER_ASSIGNED')
    ),
    CONSTRAINT ck_fiscal_issuance_references__assignment_state CHECK (
        fiscal_number_assignment_state IN ('ASSIGNED', 'NOT_ASSIGNED')
    ),
    CONSTRAINT ck_fiscal_issuance_references__integration_state CHECK (
        fiscal_issuance_state IN (
            'NOT_REQUIRED',
            'PENDING_FISCAL_ISSUANCE',
            'FISCAL_ISSUANCE_REQUESTED',
            'FISCAL_ISSUANCE_RECORDED',
            'FISCAL_ISSUANCE_REPLAYED',
            'FISCAL_ISSUANCE_CONFLICT',
            'FISCAL_ISSUANCE_FAILED_REQUEST',
            'FISCAL_ISSUANCE_FAILED_CONFIGURATION',
            'FISCAL_ISSUANCE_FAILED_SERVICE',
            'FISCAL_ISSUANCE_UNKNOWN',
            'FISCAL_ISSUANCE_MANUAL_REVIEW',
            'FISCAL_ISSUANCE_EXCEPTION_RELEASED',
            'FISCAL_ISSUANCE_RECONCILED'
        )
    ),
    CONSTRAINT ck_fiscal_issuance_references__exception_reason CHECK (
        latest_exception_reason IS NULL
        OR latest_exception_reason IN (
            'MISSING_PAYABLE_BASIS',
            'MISSING_UPSTREAM_FINALITY_REFERENCE',
            'UNAPPROVED_DISCOUNT_REFERENCE',
            'UNSUPPORTED_FISCAL_DOCUMENT_REQUEST',
            'INVALID_FISCAL_TENDER',
            'MISSING_FISCAL_TENDER',
            'INVALID_FISCAL_TAX_DETAIL',
            'INVALID_FISCAL_DISCOUNT_PRIVILEGE_DETAIL',
            'INVALID_FISCAL_TOTAL',
            'SENSITIVE_PAYLOAD_REJECTED',
            'REQUEST_CONSTRUCTION_ERROR',
            'FISCAL_IDENTITY_NOT_FOUND',
            'FISCAL_IDENTITY_AMBIGUOUS',
            'FISCAL_IDENTITY_NOT_EFFECTIVE',
            'FISCAL_SEQUENCE_POLICY_NOT_FOUND',
            'FISCAL_SEQUENCE_POLICY_AMBIGUOUS',
            'FISCAL_SEQUENCE_POLICY_NOT_EFFECTIVE',
            'FISCAL_SEQUENCE_STATE_NOT_FOUND',
            'FISCAL_SEQUENCE_STATE_NOT_EFFECTIVE',
            'FISCAL_NUMBER_ALLOCATION_FAILED',
            'FISCAL_DOCUMENT_NUMBER_FORMAT_FAILED',
            'FISCAL_DOCUMENT_IDEMPOTENCY_CONFLICT',
            'REPLAY_MISMATCH',
            'DUPLICATE_REFERENCE_DETECTED',
            'PERSISTENCE_NOT_CONFIGURED',
            'INVALID_PERSISTENCE_CONFIGURATION',
            'PERSISTENCE_WRITE_FAILED',
            'FISCAL_NUMBER_ASSIGNMENT_INCOMPLETE',
            'POST_TIMEOUT',
            'NETWORK_DISCONNECT_AFTER_POSSIBLE_COMMIT',
            'GET_READBACK_NOT_FOUND',
            'GET_READBACK_SERVICE_FAILED',
            'GET_READBACK_INCONCLUSIVE',
            'CENTRAL_PMS_REFERENCE_PERSISTENCE_FAILED',
            'MANUAL_REVIEW_REQUIRED',
            'MANUAL_RELEASE_REQUESTED_AFTER_FISCAL_FAILURE',
            'FISCAL_REFERENCE_MISMATCH',
            'RECONCILIATION_REQUIRED',
            'RECONCILIATION_CLOSED'
        )
    ),
    CONSTRAINT ck_fiscal_issuance_references__error_posture CHECK (
        latest_error_posture IS NULL
        OR latest_error_posture IN (
            'DO_NOT_RETRY_WITHOUT_REQUEST_CHANGE',
            'RETRY_AFTER_CONFIGURATION_CORRECTION',
            'RETRY_AFTER_SERVICE_RECOVERY'
        )
    ),
    CONSTRAINT ck_fiscal_issuance_references__semantic_request_hash_status CHECK (
        semantic_request_hash_status IS NULL
        OR semantic_request_hash_status IN ('UNAVAILABLE', 'INCOMPLETE', 'AVAILABLE')
    ),
    CONSTRAINT ck_fiscal_issuance_references__semantic_request_hash_available_complete CHECK (
        semantic_request_hash_status IS DISTINCT FROM 'AVAILABLE'
        OR (
            semantic_request_hash_value IS NOT NULL
            AND semantic_request_hash_algorithm IS NOT NULL
            AND semantic_request_hash_source_version IS NOT NULL
            AND semantic_request_hash_source_fact_count IS NOT NULL
            AND semantic_request_hash_source_fact_count > 0
        )
    ),
    CONSTRAINT ck_fiscal_issuance_references__complete_recorded_evidence CHECK (
        fiscal_issuance_state NOT IN (
            'FISCAL_ISSUANCE_RECORDED',
            'FISCAL_ISSUANCE_REPLAYED',
            'FISCAL_ISSUANCE_RECONCILED'
        )
        OR (
            pos_server_fiscal_document_id IS NOT NULL
            AND fiscal_identity_id IS NOT NULL
            AND fiscal_sequence_policy_id IS NOT NULL
            AND fiscal_sequence_value IS NOT NULL
            AND fiscal_document_number IS NOT NULL
            AND fiscal_number_assigned_at IS NOT NULL
            AND fiscal_issuance_evidence_status = 'FISCAL_DOCUMENT_NUMBER_ASSIGNED'
            AND fiscal_number_assignment_state = 'ASSIGNED'
        )
    ),
    CONSTRAINT ck_fiscal_issuance_references__exception_states_have_reason CHECK (
        fiscal_issuance_state NOT IN (
            'FISCAL_ISSUANCE_CONFLICT',
            'FISCAL_ISSUANCE_FAILED_REQUEST',
            'FISCAL_ISSUANCE_FAILED_CONFIGURATION',
            'FISCAL_ISSUANCE_FAILED_SERVICE',
            'FISCAL_ISSUANCE_UNKNOWN',
            'FISCAL_ISSUANCE_MANUAL_REVIEW',
            'FISCAL_ISSUANCE_EXCEPTION_RELEASED'
        )
        OR latest_exception_reason IS NOT NULL
    )
);

ALTER TABLE core.fiscal_issuance_references
    ADD COLUMN IF NOT EXISTS semantic_request_hash_status varchar(40);

ALTER TABLE core.fiscal_issuance_references
    ADD COLUMN IF NOT EXISTS semantic_request_hash_value varchar(64);

ALTER TABLE core.fiscal_issuance_references
    ADD COLUMN IF NOT EXISTS semantic_request_hash_algorithm varchar(32);

ALTER TABLE core.fiscal_issuance_references
    ADD COLUMN IF NOT EXISTS semantic_request_hash_source_version varchar(80);

ALTER TABLE core.fiscal_issuance_references
    ADD COLUMN IF NOT EXISTS semantic_request_hash_source_fact_count integer;

ALTER TABLE core.fiscal_issuance_references
    ADD COLUMN IF NOT EXISTS semantic_request_hash_safe_summary varchar(240);

ALTER TABLE core.fiscal_issuance_references
    ADD COLUMN IF NOT EXISTS semantic_request_hash_recorded_at timestamptz;

ALTER TABLE core.fiscal_issuance_references
    ADD CONSTRAINT fk_fiscal_issuance_references__payment_confirmation_id
    FOREIGN KEY (payment_confirmation_id)
    REFERENCES core.payment_confirmations(payment_confirmation_id)
    DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.fiscal_issuance_references
    ADD CONSTRAINT fk_fiscal_issuance_references__payment_attempt_id
    FOREIGN KEY (payment_attempt_id)
    REFERENCES core.payment_attempts(payment_attempt_id)
    DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.fiscal_issuance_references
    ADD CONSTRAINT fk_fiscal_issuance_references__parking_session_id
    FOREIGN KEY (parking_session_id)
    REFERENCES core.parking_sessions(parking_session_id)
    DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.fiscal_issuance_references
    ADD CONSTRAINT fk_fiscal_issuance_references__tariff_snapshot_id
    FOREIGN KEY (tariff_snapshot_id)
    REFERENCES core.tariff_snapshots(tariff_snapshot_id)
    DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.fiscal_issuance_references
    ADD CONSTRAINT fk_fiscal_issuance_references__site_id
    FOREIGN KEY (site_id)
    REFERENCES sites.sites(site_id)
    DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.fiscal_issuance_references
    ADD CONSTRAINT fk_fiscal_issuance_references__recorded_by_service_identity_id
    FOREIGN KEY (recorded_by_service_identity_id)
    REFERENCES identity.service_identities(service_identity_id)
    DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.fiscal_issuance_references
    ADD CONSTRAINT fk_fiscal_issuance_references__updated_by_service_identity_id
    FOREIGN KEY (updated_by_service_identity_id)
    REFERENCES identity.service_identities(service_identity_id)
    DEFERRABLE INITIALLY IMMEDIATE;

CREATE UNIQUE INDEX IF NOT EXISTS ux_fiscal_issuance_references__active_payment_confirmation
    ON core.fiscal_issuance_references (payment_confirmation_id)
    WHERE is_active = true;

CREATE UNIQUE INDEX IF NOT EXISTS ux_fiscal_issuance_references__active_idempotency_scope
    ON core.fiscal_issuance_references (site_pos_server_id, fiscal_document_type_code_id, upstream_finality_reference)
    WHERE is_active = true
      AND site_pos_server_id IS NOT NULL
      AND fiscal_document_type_code_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_fiscal_issuance_references__active_pos_document
    ON core.fiscal_issuance_references (pos_server_fiscal_document_id)
    WHERE is_active = true
      AND pos_server_fiscal_document_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_fiscal_issuance_references__active_fiscal_number_scope
    ON core.fiscal_issuance_references (
        site_pos_server_id,
        fiscal_identity_id,
        fiscal_sequence_policy_id,
        fiscal_document_number
    )
    WHERE is_active = true
      AND site_pos_server_id IS NOT NULL
      AND fiscal_identity_id IS NOT NULL
      AND fiscal_sequence_policy_id IS NOT NULL
      AND fiscal_document_number IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_fiscal_issuance_references__state
    ON core.fiscal_issuance_references (fiscal_issuance_state);

CREATE INDEX IF NOT EXISTS ix_fiscal_issuance_references__upstream_finality_reference
    ON core.fiscal_issuance_references (upstream_finality_reference);

CREATE TABLE IF NOT EXISTS core.fiscal_issuance_attempt_history (
    fiscal_issuance_attempt_id uuid DEFAULT gen_random_uuid() NOT NULL,
    fiscal_issuance_reference_id uuid,
    payment_confirmation_id uuid NOT NULL,
    attempt_sequence_number integer NOT NULL,
    trigger_source varchar(60) NOT NULL,
    action_type varchar(80) NOT NULL,
    request_correlation_id uuid,
    upstream_finality_reference varchar(200) NOT NULL,
    request_semantic_hash_ref varchar(200),
    pos_server_http_status integer,
    pos_server_response_code varchar(120),
    result_classification varchar(40),
    fiscal_issuance_evidence_status varchar(80),
    fiscal_number_assignment_state varchar(40),
    pos_server_fiscal_document_id uuid,
    error_code varchar(120),
    error_posture varchar(80),
    attempted_at timestamptz DEFAULT now() NOT NULL,
    completed_at timestamptz,
    actor_service_identity_id uuid,
    outcome_classification varchar(80) NOT NULL,
    operator_note_ref varchar(160),
    CONSTRAINT pk_fiscal_issuance_attempt_history PRIMARY KEY (fiscal_issuance_attempt_id),
    CONSTRAINT ck_fiscal_issuance_attempt_history__attempt_sequence_positive CHECK (attempt_sequence_number > 0),
    CONSTRAINT ck_fiscal_issuance_attempt_history__trigger_source CHECK (
        trigger_source IN ('AUTOMATIC', 'OPERATOR_TRIGGERED', 'RECONCILIATION_TRIGGERED')
    ),
    CONSTRAINT ck_fiscal_issuance_attempt_history__action_type CHECK (
        action_type IN ('CREATE', 'RETRY', 'REPLAY', 'READBACK', 'RECONCILIATION_CLOSE', 'MANUAL_REVIEW_ESCALATION')
    ),
    CONSTRAINT ck_fiscal_issuance_attempt_history__result_classification CHECK (
        result_classification IS NULL
        OR result_classification IN ('NEWLY_CREATED', 'IDEMPOTENT_REPLAY')
    ),
    CONSTRAINT ck_fiscal_issuance_attempt_history__evidence_status CHECK (
        fiscal_issuance_evidence_status IS NULL
        OR fiscal_issuance_evidence_status IN ('FISCAL_DOCUMENT_NUMBER_ASSIGNED')
    ),
    CONSTRAINT ck_fiscal_issuance_attempt_history__assignment_state CHECK (
        fiscal_number_assignment_state IS NULL
        OR fiscal_number_assignment_state IN ('ASSIGNED', 'NOT_ASSIGNED')
    ),
    CONSTRAINT ck_fiscal_issuance_attempt_history__error_posture CHECK (
        error_posture IS NULL
        OR error_posture IN (
            'DO_NOT_RETRY_WITHOUT_REQUEST_CHANGE',
            'RETRY_AFTER_CONFIGURATION_CORRECTION',
            'RETRY_AFTER_SERVICE_RECOVERY'
        )
    )
);

ALTER TABLE core.fiscal_issuance_attempt_history
    ADD CONSTRAINT fk_fiscal_issuance_attempt_history__reference_id
    FOREIGN KEY (fiscal_issuance_reference_id)
    REFERENCES core.fiscal_issuance_references(fiscal_issuance_reference_id)
    DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.fiscal_issuance_attempt_history
    ADD CONSTRAINT fk_fiscal_issuance_attempt_history__payment_confirmation_id
    FOREIGN KEY (payment_confirmation_id)
    REFERENCES core.payment_confirmations(payment_confirmation_id)
    DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.fiscal_issuance_attempt_history
    ADD CONSTRAINT fk_fiscal_issuance_attempt_history__actor_service_identity_id
    FOREIGN KEY (actor_service_identity_id)
    REFERENCES identity.service_identities(service_identity_id)
    DEFERRABLE INITIALLY IMMEDIATE;

CREATE UNIQUE INDEX IF NOT EXISTS ux_fiscal_issuance_attempt_history__reference_sequence
    ON core.fiscal_issuance_attempt_history (fiscal_issuance_reference_id, attempt_sequence_number)
    WHERE fiscal_issuance_reference_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_fiscal_issuance_attempt_history__payment_confirmation
    ON core.fiscal_issuance_attempt_history (payment_confirmation_id, attempted_at DESC);

CREATE TABLE IF NOT EXISTS core.fiscal_issuance_exception_reviews (
    fiscal_issuance_exception_review_id uuid DEFAULT gen_random_uuid() NOT NULL,
    fiscal_issuance_reference_id uuid,
    payment_confirmation_id uuid NOT NULL,
    current_exception_state varchar(80) NOT NULL,
    exception_reason_code varchar(120) NOT NULL,
    exception_category varchar(80) NOT NULL,
    review_status varchar(60) NOT NULL,
    assigned_reviewer_ref varchar(160),
    supervisor_escalation_required boolean DEFAULT false NOT NULL,
    manual_release_requested boolean DEFAULT false NOT NULL,
    manual_release_reference_id uuid,
    incident_reference varchar(160),
    reconciliation_status varchar(60),
    reconciliation_closed_at timestamptz,
    reconciliation_closed_by_ref varchar(160),
    latest_readback_status varchar(80),
    latest_mismatch_reason varchar(160),
    customer_impacting boolean DEFAULT false NOT NULL,
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL,
    CONSTRAINT pk_fiscal_issuance_exception_reviews PRIMARY KEY (fiscal_issuance_exception_review_id)
);

ALTER TABLE core.fiscal_issuance_exception_reviews
    ADD CONSTRAINT fk_fiscal_issuance_exception_reviews__reference_id
    FOREIGN KEY (fiscal_issuance_reference_id)
    REFERENCES core.fiscal_issuance_references(fiscal_issuance_reference_id)
    DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.fiscal_issuance_exception_reviews
    ADD CONSTRAINT fk_fiscal_issuance_exception_reviews__payment_confirmation_id
    FOREIGN KEY (payment_confirmation_id)
    REFERENCES core.payment_confirmations(payment_confirmation_id)
    DEFERRABLE INITIALLY IMMEDIATE;

CREATE INDEX IF NOT EXISTS ix_fiscal_issuance_exception_reviews__queue
    ON core.fiscal_issuance_exception_reviews (review_status, exception_category, updated_at DESC);

CREATE TABLE IF NOT EXISTS core.fiscal_issuance_readback_reconciliations (
    fiscal_issuance_readback_id uuid DEFAULT gen_random_uuid() NOT NULL,
    fiscal_issuance_reference_id uuid,
    payment_confirmation_id uuid NOT NULL,
    pos_server_fiscal_document_id uuid,
    readback_requested_at timestamptz DEFAULT now() NOT NULL,
    readback_completed_at timestamptz,
    readback_http_status integer,
    readback_result_code varchar(120),
    readback_fiscal_document_number varchar(120),
    readback_evidence_status varchar(80),
    readback_assignment_state varchar(40),
    comparison_result varchar(40) NOT NULL,
    mismatch_reason varchar(160),
    reconciliation_action varchar(120),
    reconciliation_closure_reference varchar(160),
    actor_service_identity_id uuid,
    CONSTRAINT pk_fiscal_issuance_readback_reconciliations PRIMARY KEY (fiscal_issuance_readback_id),
    CONSTRAINT ck_fiscal_issuance_readback_reconciliations__comparison_result CHECK (
        comparison_result IN ('MATCHED', 'MISMATCHED', 'INCONCLUSIVE', 'NOT_FOUND', 'SERVICE_FAILED')
    )
);

ALTER TABLE core.fiscal_issuance_readback_reconciliations
    ADD CONSTRAINT fk_fiscal_issuance_readback_reconciliations__reference_id
    FOREIGN KEY (fiscal_issuance_reference_id)
    REFERENCES core.fiscal_issuance_references(fiscal_issuance_reference_id)
    DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.fiscal_issuance_readback_reconciliations
    ADD CONSTRAINT fk_fiscal_issuance_readback_reconciliations__payment_confirmation_id
    FOREIGN KEY (payment_confirmation_id)
    REFERENCES core.payment_confirmations(payment_confirmation_id)
    DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.fiscal_issuance_readback_reconciliations
    ADD CONSTRAINT fk_fiscal_issuance_readback_reconciliations__actor_service_identity_id
    FOREIGN KEY (actor_service_identity_id)
    REFERENCES identity.service_identities(service_identity_id)
    DEFERRABLE INITIALLY IMMEDIATE;

CREATE INDEX IF NOT EXISTS ix_fiscal_issuance_readback_reconciliations__payment_confirmation
    ON core.fiscal_issuance_readback_reconciliations (payment_confirmation_id, readback_requested_at DESC);

CREATE TABLE IF NOT EXISTS core.fiscal_issuance_retry_command_preparations (
    retry_command_preparation_attempt_id uuid DEFAULT gen_random_uuid() NOT NULL,
    fiscal_issuance_reference_id uuid NOT NULL,
    payment_confirmation_id uuid,
    payment_attempt_id uuid,
    parking_session_id uuid,
    site_id uuid,
    site_pos_server_id uuid,
    site_pos_server_ref varchar(128),
    latest_readback_classification varchar(40),
    retry_eligibility_decision varchar(40) NOT NULL,
    command_preparation_status varchar(40) NOT NULL,
    command_block_reason_code varchar(160),
    semantic_request_hash_availability varchar(80) NOT NULL,
    idempotency_context_availability varchar(80) NOT NULL,
    attempted_at timestamptz DEFAULT now() NOT NULL,
    safe_summary varchar(240) NOT NULL,
    correlation_id uuid,
    actor_service_identity_id uuid,
    created_at timestamptz DEFAULT now() NOT NULL,
    CONSTRAINT pk_fiscal_issuance_retry_command_preparations PRIMARY KEY (retry_command_preparation_attempt_id),
    CONSTRAINT ck_fiscal_issuance_retry_command_preparations__readback_classification CHECK (
        latest_readback_classification IS NULL
        OR latest_readback_classification IN (
            'MATCHED',
            'NOT_FOUND',
            'MISMATCH',
            'FAILED',
            'UNAVAILABLE',
            'UNKNOWN',
            'IDENTIFIER_MISSING',
            'NOT_SUPPORTED_YET'
        )
    ),
    CONSTRAINT ck_fiscal_issuance_retry_command_preparations__eligibility_decision CHECK (
        retry_eligibility_decision IN ('NOT_EVALUATED', 'ELIGIBLE', 'BLOCKED', 'UNAVAILABLE', 'NOT_REQUIRED')
    ),
    CONSTRAINT ck_fiscal_issuance_retry_command_preparations__preparation_status CHECK (
        command_preparation_status IN ('NOT_PREPARED', 'PREPARED_NON_EXECUTABLE', 'BLOCKED', 'UNAVAILABLE')
    ),
    CONSTRAINT ck_fiscal_issuance_retry_command_preparations__semantic_hash_status CHECK (
        semantic_request_hash_availability IN (
            'NOT_AVAILABLE_IN_CURRENT_MODEL',
            'AVAILABLE_AND_CONFIRMED',
            'REQUIRED_BUT_MISSING',
            'REQUIRED_BUT_UNCONFIRMED'
        )
    ),
    CONSTRAINT ck_fiscal_issuance_retry_command_preparations__idempotency_status CHECK (
        idempotency_context_availability IN (
            'NOT_EVALUATED',
            'AVAILABLE',
            'MISSING_UPSTREAM_FINALITY_REFERENCE',
            'NEW_UPSTREAM_FINALITY_REFERENCE_REJECTED'
        )
    )
);

ALTER TABLE core.fiscal_issuance_retry_command_preparations
    ADD CONSTRAINT fk_fiscal_issuance_retry_command_preparations__reference_id
    FOREIGN KEY (fiscal_issuance_reference_id)
    REFERENCES core.fiscal_issuance_references(fiscal_issuance_reference_id)
    DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.fiscal_issuance_retry_command_preparations
    ADD CONSTRAINT fk_fiscal_issuance_retry_command_preparations__actor_service_identity_id
    FOREIGN KEY (actor_service_identity_id)
    REFERENCES identity.service_identities(service_identity_id)
    DEFERRABLE INITIALLY IMMEDIATE;

CREATE INDEX IF NOT EXISTS ix_fiscal_issuance_retry_command_preparations__reference_attempted
    ON core.fiscal_issuance_retry_command_preparations (fiscal_issuance_reference_id, attempted_at DESC);

CREATE TABLE IF NOT EXISTS core.fiscal_issuance_retry_schedule_preparations (
    retry_schedule_preparation_attempt_id uuid DEFAULT gen_random_uuid() NOT NULL,
    fiscal_issuance_reference_id uuid NOT NULL,
    retry_command_preparation_attempt_id uuid,
    payment_confirmation_id uuid,
    payment_attempt_id uuid,
    parking_session_id uuid,
    site_id uuid,
    site_pos_server_id uuid,
    site_pos_server_ref varchar(128),
    latest_readback_classification varchar(40),
    retry_eligibility_decision varchar(40) NOT NULL,
    semantic_request_hash_availability varchar(80) NOT NULL,
    idempotency_context_availability varchar(80) NOT NULL,
    scheduling_preparation_status varchar(40) NOT NULL,
    scheduling_block_reason_code varchar(160),
    requested_at timestamptz DEFAULT now() NOT NULL,
    earliest_eligible_at timestamptz,
    safe_summary varchar(240) NOT NULL,
    correlation_id uuid,
    actor_service_identity_id uuid,
    created_at timestamptz DEFAULT now() NOT NULL,
    CONSTRAINT pk_fiscal_issuance_retry_schedule_preparations PRIMARY KEY (retry_schedule_preparation_attempt_id),
    CONSTRAINT ck_fiscal_issuance_retry_schedule_preparations__readback_classification CHECK (
        latest_readback_classification IS NULL
        OR latest_readback_classification IN (
            'MATCHED',
            'NOT_FOUND',
            'MISMATCH',
            'FAILED',
            'UNAVAILABLE',
            'UNKNOWN',
            'IDENTIFIER_MISSING',
            'NOT_SUPPORTED_YET'
        )
    ),
    CONSTRAINT ck_fiscal_issuance_retry_schedule_preparations__eligibility_decision CHECK (
        retry_eligibility_decision IN ('NOT_EVALUATED', 'ELIGIBLE', 'BLOCKED', 'UNAVAILABLE', 'NOT_REQUIRED')
    ),
    CONSTRAINT ck_fiscal_issuance_retry_schedule_preparations__semantic_hash_status CHECK (
        semantic_request_hash_availability IN (
            'NOT_AVAILABLE_IN_CURRENT_MODEL',
            'AVAILABLE_AND_CONFIRMED',
            'REQUIRED_BUT_MISSING',
            'REQUIRED_BUT_UNCONFIRMED'
        )
    ),
    CONSTRAINT ck_fiscal_issuance_retry_schedule_preparations__idempotency_status CHECK (
        idempotency_context_availability IN (
            'NOT_EVALUATED',
            'AVAILABLE',
            'MISSING_UPSTREAM_FINALITY_REFERENCE',
            'NEW_UPSTREAM_FINALITY_REFERENCE_REJECTED'
        )
    ),
    CONSTRAINT ck_fiscal_issuance_retry_schedule_preparations__status CHECK (
        scheduling_preparation_status IN (
            'NOT_PREPARED',
            'DISABLED',
            'SCHEDULED_PREPARED',
            'BLOCKED',
            'UNAVAILABLE'
        )
    ),
    CONSTRAINT ck_fiscal_issuance_retry_schedule_preparations__prepared_has_command_audit CHECK (
        scheduling_preparation_status <> 'SCHEDULED_PREPARED'
        OR retry_command_preparation_attempt_id IS NOT NULL
    )
);

ALTER TABLE core.fiscal_issuance_retry_schedule_preparations
    ADD CONSTRAINT fk_fiscal_issuance_retry_schedule_preparations__reference_id
    FOREIGN KEY (fiscal_issuance_reference_id)
    REFERENCES core.fiscal_issuance_references(fiscal_issuance_reference_id)
    DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.fiscal_issuance_retry_schedule_preparations
    ADD CONSTRAINT fk_fiscal_issuance_retry_schedule_preparations__command_preparation_id
    FOREIGN KEY (retry_command_preparation_attempt_id)
    REFERENCES core.fiscal_issuance_retry_command_preparations(retry_command_preparation_attempt_id)
    DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.fiscal_issuance_retry_schedule_preparations
    ADD CONSTRAINT fk_fiscal_issuance_retry_schedule_preparations__actor_service_identity_id
    FOREIGN KEY (actor_service_identity_id)
    REFERENCES identity.service_identities(service_identity_id)
    DEFERRABLE INITIALLY IMMEDIATE;

CREATE INDEX IF NOT EXISTS ix_fiscal_issuance_retry_schedule_preparations__reference_requested
    ON core.fiscal_issuance_retry_schedule_preparations (fiscal_issuance_reference_id, requested_at DESC);

CREATE TABLE IF NOT EXISTS core.fiscal_issuance_retry_execution_attempts (
    retry_execution_attempt_id uuid DEFAULT gen_random_uuid() NOT NULL,
    fiscal_issuance_reference_id uuid NOT NULL,
    retry_command_preparation_attempt_id uuid,
    retry_schedule_preparation_attempt_id uuid,
    readback_classification_basis varchar(40),
    semantic_request_hash_value varchar(64),
    semantic_request_hash_algorithm varchar(32),
    semantic_request_hash_source_version varchar(80),
    upstream_finality_reference varchar(200),
    execution_status varchar(40) NOT NULL,
    block_reason_code varchar(160),
    pos_server_outcome varchar(40),
    pos_server_result_classification varchar(40),
    pos_server_fiscal_document_id uuid,
    fiscal_document_number varchar(80),
    fiscal_identity_id uuid,
    fiscal_sequence_policy_id uuid,
    fiscal_sequence_value bigint,
    fiscal_series varchar(40),
    fiscal_number_prefix_text varchar(40),
    fiscal_number_suffix_text varchar(40),
    fiscal_number_assigned_at timestamptz,
    fiscal_number_assigned_by_ref varchar(160),
    attempted_at timestamptz DEFAULT now() NOT NULL,
    completed_at timestamptz,
    actor_service_identity_id uuid,
    correlation_id uuid,
    safe_summary varchar(240) NOT NULL,
    created_at timestamptz DEFAULT now() NOT NULL,
    CONSTRAINT pk_fiscal_issuance_retry_execution_attempts PRIMARY KEY (retry_execution_attempt_id),
    CONSTRAINT ck_fiscal_issuance_retry_execution_attempts__readback_classification CHECK (
        readback_classification_basis IS NULL
        OR readback_classification_basis IN (
            'MATCHED',
            'NOT_FOUND',
            'MISMATCH',
            'FAILED',
            'UNAVAILABLE',
            'UNKNOWN',
            'IDENTIFIER_MISSING',
            'NOT_SUPPORTED_YET'
        )
    ),
    CONSTRAINT ck_fiscal_issuance_retry_execution_attempts__status CHECK (
        execution_status IN (
            'NOT_ATTEMPTED',
            'DISABLED',
            'DRY_RUN_READY',
            'EXECUTED',
            'REPLAY_MATCHED',
            'CONFLICT',
            'BLOCKED',
            'UNAVAILABLE',
            'UNKNOWN',
            'FAILED'
        )
    ),
    CONSTRAINT ck_fiscal_issuance_retry_execution_attempts__pos_outcome CHECK (
        pos_server_outcome IS NULL
        OR pos_server_outcome IN (
            'ACCEPTED',
            'CONFLICT',
            'FAILED_REQUEST',
            'FAILED_CONFIGURATION',
            'FAILED_SERVICE',
            'INVALID_RESPONSE'
        )
    ),
    CONSTRAINT ck_fiscal_issuance_retry_execution_attempts__result_classification CHECK (
        pos_server_result_classification IS NULL
        OR pos_server_result_classification IN ('NEWLY_CREATED', 'IDEMPOTENT_REPLAY')
    )
);

ALTER TABLE core.fiscal_issuance_retry_execution_attempts
    ADD CONSTRAINT fk_fiscal_issuance_retry_execution_attempts__reference_id
    FOREIGN KEY (fiscal_issuance_reference_id)
    REFERENCES core.fiscal_issuance_references(fiscal_issuance_reference_id)
    DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.fiscal_issuance_retry_execution_attempts
    ADD CONSTRAINT fk_fiscal_issuance_retry_execution_attempts__command_preparation_id
    FOREIGN KEY (retry_command_preparation_attempt_id)
    REFERENCES core.fiscal_issuance_retry_command_preparations(retry_command_preparation_attempt_id)
    DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.fiscal_issuance_retry_execution_attempts
    ADD CONSTRAINT fk_fiscal_issuance_retry_execution_attempts__schedule_preparation_id
    FOREIGN KEY (retry_schedule_preparation_attempt_id)
    REFERENCES core.fiscal_issuance_retry_schedule_preparations(retry_schedule_preparation_attempt_id)
    DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.fiscal_issuance_retry_execution_attempts
    ADD CONSTRAINT fk_fiscal_issuance_retry_execution_attempts__actor_service_identity_id
    FOREIGN KEY (actor_service_identity_id)
    REFERENCES identity.service_identities(service_identity_id)
    DEFERRABLE INITIALLY IMMEDIATE;

CREATE INDEX IF NOT EXISTS ix_fiscal_issuance_retry_execution_attempts__reference_attempted
    ON core.fiscal_issuance_retry_execution_attempts (fiscal_issuance_reference_id, attempted_at DESC);

CREATE TABLE IF NOT EXISTS core.fiscal_issuance_semantic_hash_recalculation_previews (
    semantic_hash_recalculation_preview_audit_id uuid DEFAULT gen_random_uuid() NOT NULL,
    fiscal_issuance_reference_id uuid NOT NULL,
    stored_semantic_hash_source_version varchar(80),
    required_semantic_hash_source_version varchar(80) NOT NULL,
    stored_semantic_hash_value varchar(64),
    recalculation_preview_status varchar(40) NOT NULL,
    recalculation_block_reason_code varchar(160),
    complete_original_request_facts_available boolean DEFAULT false NOT NULL,
    recalculated_hash_value varchar(64),
    recalculated_hash_algorithm varchar(32),
    recalculated_hash_source_version varchar(80),
    recalculated_source_fact_count integer,
    safe_source_summary varchar(240),
    recalculated_hash_matches_stored boolean,
    mutation_status varchar(40) NOT NULL,
    attempted_at timestamptz DEFAULT now() NOT NULL,
    safe_summary varchar(240) NOT NULL,
    correlation_id uuid,
    actor_service_identity_id uuid,
    created_at timestamptz DEFAULT now() NOT NULL,
    CONSTRAINT pk_fiscal_issuance_semantic_hash_recalculation_previews
        PRIMARY KEY (semantic_hash_recalculation_preview_audit_id),
    CONSTRAINT ck_fiscal_issuance_semantic_hash_recalculation_previews__status CHECK (
        recalculation_preview_status IN ('NOT_REQUIRED', 'PREVIEW_CALCULATED', 'BLOCKED', 'UNAVAILABLE')
    ),
    CONSTRAINT ck_fiscal_issuance_semantic_hash_recalculation_previews__mutation CHECK (
        mutation_status IN ('NOT_MUTATED')
    ),
    CONSTRAINT ck_fiscal_issuance_semantic_hash_recalculation_previews__calculated_has_hash CHECK (
        recalculation_preview_status <> 'PREVIEW_CALCULATED'
        OR (
            complete_original_request_facts_available = true
            AND recalculated_hash_value IS NOT NULL
            AND recalculated_hash_algorithm IS NOT NULL
            AND recalculated_hash_source_version IS NOT NULL
            AND recalculated_source_fact_count IS NOT NULL
            AND recalculated_source_fact_count > 0
        )
    )
);

ALTER TABLE core.fiscal_issuance_semantic_hash_recalculation_previews
    ADD CONSTRAINT fk_fiscal_issuance_semantic_hash_recalculation_previews__reference_id
    FOREIGN KEY (fiscal_issuance_reference_id)
    REFERENCES core.fiscal_issuance_references(fiscal_issuance_reference_id)
    DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.fiscal_issuance_semantic_hash_recalculation_previews
    ADD CONSTRAINT fk_fiscal_issuance_semantic_hash_recalculation_previews__actor_service_identity_id
    FOREIGN KEY (actor_service_identity_id)
    REFERENCES identity.service_identities(service_identity_id)
    DEFERRABLE INITIALLY IMMEDIATE;

CREATE INDEX IF NOT EXISTS ix_fiscal_sem_hash_recalc_previews__reference_attempted
    ON core.fiscal_issuance_semantic_hash_recalculation_previews (fiscal_issuance_reference_id, attempted_at DESC);

CREATE TABLE IF NOT EXISTS core.fiscal_issuance_semantic_hash_backfill_mutation_preparations (
    semantic_hash_backfill_mutation_audit_id uuid DEFAULT gen_random_uuid() NOT NULL,
    fiscal_issuance_reference_id uuid NOT NULL,
    semantic_hash_recalculation_preview_audit_id uuid,
    mutation_preparation_audit_id uuid,
    controlled_backfill_approval_status varchar(60) NOT NULL,
    old_semantic_hash_source_version varchar(80),
    required_semantic_hash_source_version varchar(80) NOT NULL,
    old_semantic_hash_value varchar(64),
    new_semantic_hash_value varchar(64),
    new_semantic_hash_algorithm varchar(32),
    new_semantic_hash_source_version varchar(80),
    new_semantic_hash_source_fact_count integer,
    safe_source_summary varchar(240),
    mutation_preparation_status varchar(60) NOT NULL,
    mutation_block_reason_code varchar(160),
    mutation_mode varchar(40) NOT NULL,
    mutation_enabled boolean DEFAULT false NOT NULL,
    fiscal_issuance_reference_mutated boolean DEFAULT false NOT NULL,
    attempted_at timestamptz DEFAULT now() NOT NULL,
    safe_summary varchar(240) NOT NULL,
    correlation_id uuid,
    actor_service_identity_id uuid,
    approval_reference varchar(160),
    dual_control_reference varchar(160),
    created_at timestamptz DEFAULT now() NOT NULL,
    CONSTRAINT pk_fiscal_issuance_semantic_hash_backfill_mutation_preparations
        PRIMARY KEY (semantic_hash_backfill_mutation_audit_id),
    CONSTRAINT ck_fiscal_sem_hash_backfill_mutation__approval_status CHECK (
        controlled_backfill_approval_status IN (
            'NOT_REQUIRED_CURRENT',
            'READY_FOR_CONTROLLED_BACKFILL',
            'BLOCKED',
            'PENDING_DUAL_CONTROL',
            'UNAVAILABLE'
        )
    ),
    CONSTRAINT ck_fiscal_sem_hash_backfill_mutation__status CHECK (
        mutation_preparation_status IN (
            'NOT_PREPARED',
            'PREPARED_BUT_MUTATION_DISABLED',
            'PREPARED_FOR_CONTROLLED_MUTATION',
            'MUTATED',
            'FAILED',
            'STALE',
            'DISABLED',
            'BLOCKED',
            'UNAVAILABLE'
        )
    ),
    CONSTRAINT ck_fiscal_sem_hash_backfill_mutation__mode CHECK (
        mutation_mode IN ('SINGLE_RECORD_ONLY')
    ),
    CONSTRAINT ck_fiscal_sem_hash_backfill_mutation__mutation_guard CHECK (
        fiscal_issuance_reference_mutated = false
        OR (
            fiscal_issuance_reference_mutated = true
            AND mutation_preparation_status = 'MUTATED'
            AND mutation_enabled = true
            AND mutation_preparation_audit_id IS NOT NULL
        )
    ),
    CONSTRAINT ck_fiscal_sem_hash_backfill_mutation__prepared_has_hash CHECK (
        mutation_preparation_status NOT IN (
            'PREPARED_BUT_MUTATION_DISABLED',
            'PREPARED_FOR_CONTROLLED_MUTATION',
            'MUTATED'
        )
        OR (
            semantic_hash_recalculation_preview_audit_id IS NOT NULL
            AND new_semantic_hash_value IS NOT NULL
            AND new_semantic_hash_algorithm IS NOT NULL
            AND new_semantic_hash_source_version IS NOT NULL
            AND new_semantic_hash_source_fact_count IS NOT NULL
            AND new_semantic_hash_source_fact_count > 0
        )
    )
);

ALTER TABLE core.fiscal_issuance_semantic_hash_backfill_mutation_preparations
    ADD CONSTRAINT fk_fiscal_sem_hash_backfill_mutation__reference_id
    FOREIGN KEY (fiscal_issuance_reference_id)
    REFERENCES core.fiscal_issuance_references(fiscal_issuance_reference_id)
    DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.fiscal_issuance_semantic_hash_backfill_mutation_preparations
    ADD CONSTRAINT fk_fiscal_sem_hash_backfill_mutation__preview_audit_id
    FOREIGN KEY (semantic_hash_recalculation_preview_audit_id)
    REFERENCES core.fiscal_issuance_semantic_hash_recalculation_previews(semantic_hash_recalculation_preview_audit_id)
    DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.fiscal_issuance_semantic_hash_backfill_mutation_preparations
    ADD CONSTRAINT fk_fiscal_sem_hash_backfill_mutation__prep_audit_id
    FOREIGN KEY (mutation_preparation_audit_id)
    REFERENCES core.fiscal_issuance_semantic_hash_backfill_mutation_preparations(semantic_hash_backfill_mutation_audit_id)
    DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.fiscal_issuance_semantic_hash_backfill_mutation_preparations
    ADD CONSTRAINT fk_fiscal_sem_hash_backfill_mutation__actor_service_identity_id
    FOREIGN KEY (actor_service_identity_id)
    REFERENCES identity.service_identities(service_identity_id)
    DEFERRABLE INITIALLY IMMEDIATE;

CREATE INDEX IF NOT EXISTS ix_fiscal_sem_hash_backfill_mutation__reference_attempted
    ON core.fiscal_issuance_semantic_hash_backfill_mutation_preparations (fiscal_issuance_reference_id, attempted_at DESC);

CREATE TABLE IF NOT EXISTS core.fiscal_issuance_semantic_hash_backfill_workflow_requests (
    semantic_hash_backfill_workflow_request_id uuid DEFAULT gen_random_uuid() NOT NULL,
    fiscal_issuance_reference_id uuid NOT NULL,
    semantic_hash_recalculation_preview_audit_id uuid,
    mutation_preparation_audit_id uuid,
    approval_reference varchar(160),
    dual_control_reference varchar(160),
    actor_service_identity_id uuid,
    reason_code varchar(80),
    safe_justification varchar(240),
    request_mode varchar(40) NOT NULL,
    workflow_status varchar(80) NOT NULL,
    workflow_block_reason_code varchar(160),
    mutation_invocation_posture varchar(40) NOT NULL,
    guarded_mutation_audit_id uuid,
    guarded_mutation_status varchar(60),
    execute_controlled_mutation_requested boolean DEFAULT false NOT NULL,
    mutation_invocation_enabled boolean DEFAULT false NOT NULL,
    dry_run_only boolean DEFAULT true NOT NULL,
    requested_at timestamptz DEFAULT now() NOT NULL,
    correlation_id uuid,
    safe_summary varchar(240) NOT NULL,
    created_at timestamptz DEFAULT now() NOT NULL,
    CONSTRAINT pk_fiscal_sem_hash_backfill_workflow_requests
        PRIMARY KEY (semantic_hash_backfill_workflow_request_id),
    CONSTRAINT ck_fiscal_sem_hash_backfill_workflow__request_mode CHECK (
        request_mode IN ('SINGLE_RECORD_ONLY', 'BATCH')
    ),
    CONSTRAINT ck_fiscal_sem_hash_backfill_workflow__status CHECK (
        workflow_status IN (
            'NOT_REQUESTED',
            'READY_FOR_OPERATOR_APPROVAL',
            'PREPARED_BUT_MUTATION_INVOCATION_DISABLED',
            'MUTATION_INVOKED',
            'BLOCKED',
            'UNAVAILABLE'
        )
    ),
    CONSTRAINT ck_fiscal_sem_hash_backfill_workflow__invocation_posture CHECK (
        mutation_invocation_posture IN (
            'NOT_REQUESTED',
            'DRY_RUN_ONLY',
            'DISABLED',
            'INVOKED',
            'BLOCKED'
        )
    ),
    CONSTRAINT ck_fiscal_sem_hash_backfill_workflow__guarded_status CHECK (
        guarded_mutation_status IS NULL
        OR guarded_mutation_status IN (
            'NOT_PREPARED',
            'PREPARED_BUT_MUTATION_DISABLED',
            'PREPARED_FOR_CONTROLLED_MUTATION',
            'MUTATED',
            'FAILED',
            'STALE',
            'DISABLED',
            'BLOCKED',
            'UNAVAILABLE'
        )
    )
);

ALTER TABLE core.fiscal_issuance_semantic_hash_backfill_workflow_requests
    ADD CONSTRAINT fk_fiscal_sem_hash_backfill_workflow__reference_id
    FOREIGN KEY (fiscal_issuance_reference_id)
    REFERENCES core.fiscal_issuance_references(fiscal_issuance_reference_id)
    DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.fiscal_issuance_semantic_hash_backfill_workflow_requests
    ADD CONSTRAINT fk_fiscal_sem_hash_backfill_workflow__preview_audit_id
    FOREIGN KEY (semantic_hash_recalculation_preview_audit_id)
    REFERENCES core.fiscal_issuance_semantic_hash_recalculation_previews(semantic_hash_recalculation_preview_audit_id)
    DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.fiscal_issuance_semantic_hash_backfill_workflow_requests
    ADD CONSTRAINT fk_fiscal_sem_hash_backfill_workflow__mutation_prep_audit_id
    FOREIGN KEY (mutation_preparation_audit_id)
    REFERENCES core.fiscal_issuance_semantic_hash_backfill_mutation_preparations(semantic_hash_backfill_mutation_audit_id)
    DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.fiscal_issuance_semantic_hash_backfill_workflow_requests
    ADD CONSTRAINT fk_fiscal_sem_hash_backfill_workflow__guarded_mutation_audit_id
    FOREIGN KEY (guarded_mutation_audit_id)
    REFERENCES core.fiscal_issuance_semantic_hash_backfill_mutation_preparations(semantic_hash_backfill_mutation_audit_id)
    DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE core.fiscal_issuance_semantic_hash_backfill_workflow_requests
    ADD CONSTRAINT fk_fiscal_sem_hash_backfill_workflow__actor_service_identity_id
    FOREIGN KEY (actor_service_identity_id)
    REFERENCES identity.service_identities(service_identity_id)
    DEFERRABLE INITIALLY IMMEDIATE;

CREATE INDEX IF NOT EXISTS ix_fiscal_sem_hash_backfill_workflow__reference_requested
    ON core.fiscal_issuance_semantic_hash_backfill_workflow_requests (fiscal_issuance_reference_id, requested_at DESC);

COMMENT ON TABLE core.fiscal_issuance_references IS
    'Central PMS v1.3 persistence scaffold for POS Server fiscal issuance reference evidence. Persistence/state only; no POS Server network or ExitAuthorization gating behavior.';
COMMENT ON TABLE core.fiscal_issuance_attempt_history IS
    'Central PMS v1.3 fiscal issuance attempt/history scaffold for future retry, replay, conflict, and reconciliation slices.';
COMMENT ON TABLE core.fiscal_issuance_exception_reviews IS
    'Central PMS v1.3 fiscal issuance exception/review scaffold for future Operator Console governance queues.';
COMMENT ON TABLE core.fiscal_issuance_readback_reconciliations IS
    'Central PMS v1.3 fiscal readback/reconciliation scaffold for future GET readback and reconciliation slices.';
COMMENT ON TABLE core.fiscal_issuance_retry_command_preparations IS
    'Central PMS v1.3 FEQ retry command preparation audit records only. No retry execution, scheduler, endpoint, POS Server POST, or ExitAuthorization gating behavior.';
COMMENT ON TABLE core.fiscal_issuance_retry_schedule_preparations IS
    'Central PMS v1.3 FEQ retry scheduling preparation audit records only. No executable retry job, endpoint, POS Server POST, or ExitAuthorization gating behavior.';
COMMENT ON TABLE core.fiscal_issuance_retry_execution_attempts IS
    'Central PMS v1.3 FEQ controlled retry execution attempt audit records. Single-record feature-flagged POST path only; no public endpoint, batch retry, scheduler job, ExitAuthorization, or gate behavior.';
COMMENT ON TABLE core.fiscal_issuance_semantic_hash_recalculation_previews IS
    'Central PMS v1.3 FEQ semantic hash recalculation preview audit records only. No hash backfill mutation, retry execution, endpoint, POS Server POST, or ExitAuthorization gating behavior.';
COMMENT ON TABLE core.fiscal_issuance_semantic_hash_backfill_mutation_preparations IS
    'Central PMS v1.3 FEQ semantic hash controlled single-record backfill mutation audit records. No automatic batch backfill, retry execution, endpoint, POS Server POST, or ExitAuthorization gating behavior.';
COMMENT ON TABLE core.fiscal_issuance_semantic_hash_backfill_workflow_requests IS
    'Central PMS v1.3 FEQ semantic hash internal operator workflow request audit records. Single-record governed request posture only; no public UI, batch backfill, retry execution, endpoint, POS Server POST, or ExitAuthorization gating behavior.';


-- ============================================================================
-- Promoted source patch: D:\SourceCodes\ExitPass\infra\db\patches\ExitPass_OperatorConsoleSchema_v1.2.sql
-- ============================================================================

/*
 * ExitPass v1.2 durable SQL patch.
 *
 * Operator Console schema migration draft.
 *
 * References:
 * - docs/operator-console/operator-console-schema-extension-design.md
 * - docs/operator-console/proposals/operator-console-ddl-proposal.sql
 * - docs/operator-console/proposals/operator-console-ddl-proposal-notes.md
 *
 * This patch creates Operator Console access, HR/Timekeeping shift import,
 * browser/device binding, takeover, access evaluation evidence, and statutory
 * entitlement fingerprint storage.
 *
 * Non-payment boundary:
 * The objects below must not create, mutate, route, configure, or invoke payment
 * attempts, payment confirmations, payment provider outcomes, exit
 * authorizations, gate authorization consumptions, coupon applications,
 * settlement truth records, provider routing, or payment finality.
 */

CREATE SCHEMA IF NOT EXISTS operator_console;

COMMENT ON SCHEMA operator_console IS
    'Operator Console access, device binding, HR shift import, takeover, and access evaluation support.';

DO $$ BEGIN
    CREATE TYPE operator_console.hr_identity_mapping_status_enum AS ENUM (
        'ACTIVE',
        'SUSPENDED',
        'REVOKED',
        'EXPIRED',
        'SUPERSEDED'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE operator_console.operator_shift_operational_status_enum AS ENUM (
        'SCHEDULED',
        'ACTIVE',
        'ENDED',
        'SUSPENDED',
        'REVOKED',
        'TAKEN_OVER',
        'CANCELLED',
        'IMPORT_CONFLICT'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE operator_console.shift_revocation_status_enum AS ENUM (
        'REQUESTED',
        'APPROVED',
        'REJECTED',
        'CANCELLED',
        'EFFECTIVE',
        'EXPIRED'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE operator_console.shift_takeover_status_enum AS ENUM (
        'REQUESTED',
        'PENDING_APPROVAL',
        'APPROVED',
        'REJECTED',
        'ACTIVE',
        'ENDED',
        'CANCELLED',
        'EXPIRED'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE operator_console.operator_device_binding_status_enum AS ENUM (
        'PENDING',
        'ACTIVE',
        'SUSPENDED',
        'REVOKED',
        'LOST',
        'EXPIRED',
        'RETIRED'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE operator_console.operator_device_trust_level_enum AS ENUM (
        'BROWSER_KEY_ONLY',
        'MTLS_ONLY',
        'BROWSER_KEY_AND_MTLS',
        'UNVERIFIED'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE operator_console.access_evaluation_status_enum AS ENUM (
        'ALLOWED',
        'DENIED'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE discounts.entitlement_fingerprint_status_enum AS ENUM (
        'ACTIVE',
        'SUPERSEDED',
        'REDACTED',
        'PURGED',
        'HASH_ONLY'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS operator_console.hr_identity_mappings (
    hr_identity_mapping_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    hr_provider_code varchar(64) NOT NULL,
    external_person_id_hash char(64) NOT NULL,
    external_person_id_masked varchar(64),
    external_employee_number_hash char(64),
    external_employee_number_masked varchar(64),
    mapping_status operator_console.hr_identity_mapping_status_enum NOT NULL,
    effective_from timestamptz NOT NULL,
    effective_to timestamptz,
    revoked_at timestamptz,
    revoked_by_user_id uuid,
    revoked_by_service_identity_id uuid,
    revocation_reason_code varchar(64),
    correlation_id uuid,
    created_at timestamptz DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamptz DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT pk_hr_identity_mappings PRIMARY KEY (hr_identity_mapping_id),
    CONSTRAINT fk_hr_identity_mappings__user_id FOREIGN KEY (user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_hr_identity_mappings__revoked_by_user_id FOREIGN KEY (revoked_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_hr_identity_mappings__revoked_by_service_identity_id FOREIGN KEY (revoked_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_hr_identity_mappings__created_by_user_id FOREIGN KEY (created_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_hr_identity_mappings__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_hr_identity_mappings__updated_by_user_id FOREIGN KEY (updated_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_hr_identity_mappings__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT ck_hr_identity_mappings__effective_window CHECK (effective_to IS NULL OR effective_to > effective_from),
    CONSTRAINT ck_hr_identity_mappings__row_version_positive CHECK (row_version > 0)
);

COMMENT ON TABLE operator_console.hr_identity_mappings IS
    'Maps ExitPass users to imported HR/Timekeeping identities using hashed/masked external identifiers.';

CREATE UNIQUE INDEX IF NOT EXISTS ux_hr_identity_mappings__active_external_person
    ON operator_console.hr_identity_mappings (hr_provider_code, external_person_id_hash)
    WHERE mapping_status = 'ACTIVE';

CREATE UNIQUE INDEX IF NOT EXISTS ux_hr_identity_mappings__active_user_provider
    ON operator_console.hr_identity_mappings (user_id, hr_provider_code)
    WHERE mapping_status = 'ACTIVE';

CREATE INDEX IF NOT EXISTS ix_hr_identity_mappings__user_status
    ON operator_console.hr_identity_mappings (user_id, mapping_status);

CREATE INDEX IF NOT EXISTS ix_hr_identity_mappings__correlation_id
    ON operator_console.hr_identity_mappings (correlation_id)
    WHERE correlation_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS operator_console.operator_shifts (
    operator_shift_id uuid DEFAULT gen_random_uuid() NOT NULL,
    hr_provider_code varchar(64) NOT NULL,
    external_shift_id_hash char(64) NOT NULL,
    external_shift_id_masked varchar(64),
    hr_identity_mapping_id uuid NOT NULL,
    operator_user_id uuid NOT NULL,
    site_group_id uuid NOT NULL,
    site_id uuid NOT NULL,
    scheduled_start_at timestamptz NOT NULL,
    scheduled_end_at timestamptz NOT NULL,
    source_imported_at timestamptz NOT NULL,
    import_status_code varchar(64) NOT NULL,
    source_system_code varchar(64) NOT NULL,
    source_status_code varchar(96),
    source_status_description text,
    operational_status operator_console.operator_shift_operational_status_enum NOT NULL,
    active_from timestamptz,
    active_to timestamptz,
    revoked_at timestamptz,
    revoked_by_user_id uuid,
    revocation_reason_code varchar(64),
    current_takeover_id uuid,
    correlation_id uuid,
    created_at timestamptz DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamptz DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT pk_operator_shifts PRIMARY KEY (operator_shift_id),
    CONSTRAINT fk_operator_shifts__hr_identity_mapping_id FOREIGN KEY (hr_identity_mapping_id)
        REFERENCES operator_console.hr_identity_mappings(hr_identity_mapping_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_shifts__operator_user_id FOREIGN KEY (operator_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_shifts__site_group_id FOREIGN KEY (site_group_id)
        REFERENCES sites.site_groups(site_group_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_shifts__site_id FOREIGN KEY (site_id)
        REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_shifts__revoked_by_user_id FOREIGN KEY (revoked_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_shifts__created_by_user_id FOREIGN KEY (created_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_shifts__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_shifts__updated_by_user_id FOREIGN KEY (updated_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_shifts__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT ck_operator_shifts__scheduled_window CHECK (scheduled_end_at > scheduled_start_at),
    CONSTRAINT ck_operator_shifts__active_window CHECK (active_to IS NULL OR active_from IS NULL OR active_to > active_from),
    CONSTRAINT ck_operator_shifts__row_version_positive CHECK (row_version > 0)
);

COMMENT ON TABLE operator_console.operator_shifts IS
    'Current operational state for imported HR/Timekeeping operator shifts.';

CREATE UNIQUE INDEX IF NOT EXISTS ux_operator_shifts__source_shift
    ON operator_console.operator_shifts (hr_provider_code, external_shift_id_hash);

CREATE INDEX IF NOT EXISTS ix_operator_shifts__active_operator_site_time
    ON operator_console.operator_shifts (operator_user_id, site_id, active_from, active_to)
    WHERE operational_status = 'ACTIVE';

CREATE INDEX IF NOT EXISTS ix_operator_shifts__site_time_status
    ON operator_console.operator_shifts (site_id, scheduled_start_at, scheduled_end_at, operational_status);

CREATE INDEX IF NOT EXISTS ix_operator_shifts__mapping_status
    ON operator_console.operator_shifts (hr_identity_mapping_id, operational_status);

CREATE INDEX IF NOT EXISTS ix_operator_shifts__operator_site_status
    ON operator_console.operator_shifts (operator_user_id, site_id, operational_status);

CREATE INDEX IF NOT EXISTS ix_operator_shifts__correlation_id
    ON operator_console.operator_shifts (correlation_id)
    WHERE correlation_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS operator_console.operator_shift_versions (
    operator_shift_version_id uuid DEFAULT gen_random_uuid() NOT NULL,
    operator_shift_id uuid NOT NULL,
    hr_provider_code varchar(64) NOT NULL,
    external_shift_id_hash char(64) NOT NULL,
    source_payload_hash char(64),
    source_payload_ref varchar(256),
    import_status_code varchar(64) NOT NULL,
    source_system_code varchar(64) NOT NULL,
    source_status_code varchar(96),
    source_status_description text,
    scheduled_start_at timestamptz NOT NULL,
    scheduled_end_at timestamptz NOT NULL,
    site_id uuid,
    operator_user_id uuid,
    imported_at timestamptz NOT NULL,
    imported_by_service_identity_id uuid NOT NULL,
    correlation_id uuid,
    CONSTRAINT pk_operator_shift_versions PRIMARY KEY (operator_shift_version_id),
    CONSTRAINT fk_operator_shift_versions__operator_shift_id FOREIGN KEY (operator_shift_id)
        REFERENCES operator_console.operator_shifts(operator_shift_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_shift_versions__site_id FOREIGN KEY (site_id)
        REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_shift_versions__operator_user_id FOREIGN KEY (operator_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_shift_versions__imported_by_service_identity_id FOREIGN KEY (imported_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT ck_operator_shift_versions__scheduled_window CHECK (scheduled_end_at > scheduled_start_at)
);

COMMENT ON TABLE operator_console.operator_shift_versions IS
    'Immutable import/version history for HR/Timekeeping operator shifts.';

CREATE INDEX IF NOT EXISTS ix_operator_shift_versions__shift_imported_at
    ON operator_console.operator_shift_versions (operator_shift_id, imported_at DESC);

CREATE INDEX IF NOT EXISTS ix_operator_shift_versions__source_shift
    ON operator_console.operator_shift_versions (hr_provider_code, external_shift_id_hash);

CREATE INDEX IF NOT EXISTS ix_operator_shift_versions__correlation_id
    ON operator_console.operator_shift_versions (correlation_id)
    WHERE correlation_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS operator_console.shift_revocations (
    shift_revocation_id uuid DEFAULT gen_random_uuid() NOT NULL,
    operator_shift_id uuid NOT NULL,
    revocation_status operator_console.shift_revocation_status_enum NOT NULL,
    reason_code varchar(64) NOT NULL,
    reason_note text,
    requested_by_user_id uuid NOT NULL,
    approved_by_user_id uuid,
    revoked_operator_user_id uuid NOT NULL,
    site_id uuid NOT NULL,
    requested_at timestamptz NOT NULL,
    approved_at timestamptz,
    effective_at timestamptz,
    correlation_id uuid,
    created_at timestamptz DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamptz DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT pk_shift_revocations PRIMARY KEY (shift_revocation_id),
    CONSTRAINT fk_shift_revocations__operator_shift_id FOREIGN KEY (operator_shift_id)
        REFERENCES operator_console.operator_shifts(operator_shift_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_revocations__requested_by_user_id FOREIGN KEY (requested_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_revocations__approved_by_user_id FOREIGN KEY (approved_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_revocations__revoked_operator_user_id FOREIGN KEY (revoked_operator_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_revocations__site_id FOREIGN KEY (site_id)
        REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_revocations__created_by_user_id FOREIGN KEY (created_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_revocations__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_revocations__updated_by_user_id FOREIGN KEY (updated_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_revocations__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT ck_shift_revocations__row_version_positive CHECK (row_version > 0)
);

CREATE INDEX IF NOT EXISTS ix_shift_revocations__shift_status
    ON operator_console.shift_revocations (operator_shift_id, revocation_status, requested_at DESC);

CREATE INDEX IF NOT EXISTS ix_shift_revocations__site_effective
    ON operator_console.shift_revocations (site_id, effective_at DESC);

CREATE INDEX IF NOT EXISTS ix_shift_revocations__correlation_id
    ON operator_console.shift_revocations (correlation_id)
    WHERE correlation_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS operator_console.shift_takeovers (
    shift_takeover_id uuid DEFAULT gen_random_uuid() NOT NULL,
    operator_shift_id uuid NOT NULL,
    original_operator_user_id uuid NOT NULL,
    takeover_operator_user_id uuid NOT NULL,
    takeover_status operator_console.shift_takeover_status_enum NOT NULL,
    reason_code varchar(64) NOT NULL,
    reason_note text,
    requested_by_user_id uuid NOT NULL,
    approved_by_user_id uuid,
    site_id uuid NOT NULL,
    requested_at timestamptz NOT NULL,
    approved_at timestamptz,
    active_from timestamptz,
    active_to timestamptz,
    ended_at timestamptz,
    correlation_id uuid,
    created_at timestamptz DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamptz DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT pk_shift_takeovers PRIMARY KEY (shift_takeover_id),
    CONSTRAINT fk_shift_takeovers__operator_shift_id FOREIGN KEY (operator_shift_id)
        REFERENCES operator_console.operator_shifts(operator_shift_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_takeovers__original_operator_user_id FOREIGN KEY (original_operator_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_takeovers__takeover_operator_user_id FOREIGN KEY (takeover_operator_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_takeovers__requested_by_user_id FOREIGN KEY (requested_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_takeovers__approved_by_user_id FOREIGN KEY (approved_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_takeovers__site_id FOREIGN KEY (site_id)
        REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_takeovers__created_by_user_id FOREIGN KEY (created_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_takeovers__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_takeovers__updated_by_user_id FOREIGN KEY (updated_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_takeovers__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT ck_shift_takeovers__different_users CHECK (original_operator_user_id <> takeover_operator_user_id),
    CONSTRAINT ck_shift_takeovers__active_window CHECK (active_to IS NULL OR active_from IS NULL OR active_to > active_from),
    CONSTRAINT ck_shift_takeovers__row_version_positive CHECK (row_version > 0)
);

DO $$ BEGIN
    ALTER TABLE operator_console.operator_shifts
        ADD CONSTRAINT fk_operator_shifts__current_takeover_id
        FOREIGN KEY (current_takeover_id)
        REFERENCES operator_console.shift_takeovers(shift_takeover_id)
        DEFERRABLE INITIALLY IMMEDIATE;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS ix_shift_takeovers__shift_status
    ON operator_console.shift_takeovers (operator_shift_id, takeover_status, requested_at DESC);

CREATE INDEX IF NOT EXISTS ix_shift_takeovers__active_takeover_operator
    ON operator_console.shift_takeovers (takeover_operator_user_id, site_id, active_from, active_to)
    WHERE takeover_status = 'ACTIVE';

CREATE INDEX IF NOT EXISTS ix_shift_takeovers__correlation_id
    ON operator_console.shift_takeovers (correlation_id)
    WHERE correlation_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS operator_console.operator_device_bindings (
    operator_device_binding_id uuid DEFAULT gen_random_uuid() NOT NULL,
    device_binding_code varchar(64) NOT NULL,
    device_name varchar(128) NOT NULL,
    site_group_id uuid NOT NULL,
    site_id uuid NOT NULL,
    service_identity_id uuid,
    browser_key_thumbprint char(64),
    browser_public_key_ref varchar(256),
    mtls_certificate_thumbprint char(64),
    mtls_certificate_subject varchar(256),
    mtls_certificate_expires_at timestamptz,
    device_status operator_console.operator_device_binding_status_enum NOT NULL,
    trust_level operator_console.operator_device_trust_level_enum NOT NULL,
    binding_source varchar(64) NOT NULL,
    last_seen_at timestamptz,
    revoked_at timestamptz,
    revocation_reason_code varchar(64),
    lost_reported_at timestamptz,
    correlation_id uuid,
    created_at timestamptz DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamptz DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT pk_operator_device_bindings PRIMARY KEY (operator_device_binding_id),
    CONSTRAINT fk_operator_device_bindings__site_group_id FOREIGN KEY (site_group_id)
        REFERENCES sites.site_groups(site_group_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_device_bindings__site_id FOREIGN KEY (site_id)
        REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_device_bindings__service_identity_id FOREIGN KEY (service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_device_bindings__created_by_user_id FOREIGN KEY (created_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_device_bindings__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_device_bindings__updated_by_user_id FOREIGN KEY (updated_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_device_bindings__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT ck_operator_device_bindings__has_trust_material CHECK (
        browser_key_thumbprint IS NOT NULL
        OR mtls_certificate_thumbprint IS NOT NULL
        OR service_identity_id IS NOT NULL
    ),
    CONSTRAINT ck_operator_device_bindings__row_version_positive CHECK (row_version > 0)
);

COMMENT ON TABLE operator_console.operator_device_bindings IS
    'Operator Console browser/device trust binding, separate from gate devices.';

CREATE UNIQUE INDEX IF NOT EXISTS ux_operator_device_bindings__device_binding_code
    ON operator_console.operator_device_bindings (device_binding_code);

CREATE UNIQUE INDEX IF NOT EXISTS ux_operator_device_bindings__active_browser_key
    ON operator_console.operator_device_bindings (browser_key_thumbprint)
    WHERE device_status = 'ACTIVE' AND browser_key_thumbprint IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_operator_device_bindings__active_mtls_thumbprint
    ON operator_console.operator_device_bindings (mtls_certificate_thumbprint)
    WHERE device_status = 'ACTIVE' AND mtls_certificate_thumbprint IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_operator_device_bindings__active_service_identity
    ON operator_console.operator_device_bindings (service_identity_id)
    WHERE device_status = 'ACTIVE' AND service_identity_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_operator_device_bindings__site_status
    ON operator_console.operator_device_bindings (site_id, device_status, trust_level);

CREATE INDEX IF NOT EXISTS ix_operator_device_bindings__last_seen
    ON operator_console.operator_device_bindings (last_seen_at DESC);

CREATE INDEX IF NOT EXISTS ix_operator_device_bindings__correlation_id
    ON operator_console.operator_device_bindings (correlation_id)
    WHERE correlation_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS operator_console.operator_device_assignment_history (
    operator_device_assignment_history_id uuid DEFAULT gen_random_uuid() NOT NULL,
    operator_device_binding_id uuid NOT NULL,
    site_group_id uuid NOT NULL,
    site_id uuid NOT NULL,
    assignment_status_code varchar(64) NOT NULL,
    assignment_source_code varchar(64) NOT NULL,
    assignment_reason_code varchar(64),
    assigned_at timestamptz NOT NULL,
    assigned_by_user_id uuid,
    assigned_by_service_identity_id uuid,
    effective_from timestamptz NOT NULL,
    effective_to timestamptz,
    ended_at timestamptz,
    ended_by_user_id uuid,
    ended_by_service_identity_id uuid,
    end_reason_code varchar(64),
    correlation_id uuid,
    created_at timestamptz DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    CONSTRAINT pk_operator_device_assignment_history PRIMARY KEY (operator_device_assignment_history_id),
    CONSTRAINT fk_operator_device_assignment_history__binding_id FOREIGN KEY (operator_device_binding_id)
        REFERENCES operator_console.operator_device_bindings(operator_device_binding_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_device_assignment_history__site_group_id FOREIGN KEY (site_group_id)
        REFERENCES sites.site_groups(site_group_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_device_assignment_history__site_id FOREIGN KEY (site_id)
        REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_device_assignment_history__assigned_by_user_id FOREIGN KEY (assigned_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_op_dev_assign_hist__assigned_svc_identity FOREIGN KEY (assigned_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_device_assignment_history__ended_by_user_id FOREIGN KEY (ended_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_op_dev_assign_hist__ended_svc_identity FOREIGN KEY (ended_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_device_assignment_history__created_by_user_id FOREIGN KEY (created_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_op_dev_assign_hist__created_svc_identity FOREIGN KEY (created_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT ck_operator_device_assignment_history__effective_window CHECK (effective_to IS NULL OR effective_to > effective_from)
);

COMMENT ON TABLE operator_console.operator_device_assignment_history IS
    'Reconstructable Operator Console device/site assignment history for authorization audit.';

CREATE INDEX IF NOT EXISTS ix_operator_device_assignment_history__binding_time
    ON operator_console.operator_device_assignment_history (operator_device_binding_id, effective_from DESC);

CREATE INDEX IF NOT EXISTS ix_operator_device_assignment_history__site_time
    ON operator_console.operator_device_assignment_history (site_id, effective_from DESC, effective_to);

CREATE INDEX IF NOT EXISTS ix_operator_device_assignment_history__active_binding_site
    ON operator_console.operator_device_assignment_history (operator_device_binding_id, site_id, effective_from, effective_to)
    WHERE effective_to IS NULL;

CREATE INDEX IF NOT EXISTS ix_operator_device_assignment_history__correlation_id
    ON operator_console.operator_device_assignment_history (correlation_id)
    WHERE correlation_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS operator_console.operator_access_evaluations (
    operator_access_evaluation_id uuid DEFAULT gen_random_uuid() NOT NULL,
    correlation_id uuid,
    requested_action varchar(96) NOT NULL,
    evaluation_status operator_console.access_evaluation_status_enum NOT NULL,
    operator_user_id uuid NOT NULL,
    hr_identity_mapping_id uuid,
    operator_device_binding_id uuid,
    operator_shift_id uuid,
    shift_takeover_id uuid,
    site_group_id uuid,
    site_id uuid,
    target_entity_type varchar(64),
    target_entity_id uuid,
    evaluated_at timestamptz NOT NULL,
    decision_snapshot_json jsonb,
    audit_event_id uuid,
    created_at timestamptz DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    CONSTRAINT pk_operator_access_evaluations PRIMARY KEY (operator_access_evaluation_id),
    CONSTRAINT fk_operator_access_evaluations__operator_user_id FOREIGN KEY (operator_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_access_evaluations__hr_identity_mapping_id FOREIGN KEY (hr_identity_mapping_id)
        REFERENCES operator_console.hr_identity_mappings(hr_identity_mapping_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_access_evaluations__operator_device_binding_id FOREIGN KEY (operator_device_binding_id)
        REFERENCES operator_console.operator_device_bindings(operator_device_binding_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_access_evaluations__operator_shift_id FOREIGN KEY (operator_shift_id)
        REFERENCES operator_console.operator_shifts(operator_shift_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_access_evaluations__shift_takeover_id FOREIGN KEY (shift_takeover_id)
        REFERENCES operator_console.shift_takeovers(shift_takeover_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_access_evaluations__site_group_id FOREIGN KEY (site_group_id)
        REFERENCES sites.site_groups(site_group_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_access_evaluations__site_id FOREIGN KEY (site_id)
        REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_access_evaluations__audit_event_id FOREIGN KEY (audit_event_id)
        REFERENCES audit.audit_events(audit_event_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_access_evaluations__created_by_user_id FOREIGN KEY (created_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_access_evaluations__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE
);

COMMENT ON TABLE operator_console.operator_access_evaluations IS
    'Persisted access evaluation evidence for denied access and controlled Operator Console actions only.';

COMMENT ON COLUMN operator_console.operator_access_evaluations.requested_action IS
    'Controlled action code. Access evaluation runs at workflow start and before every controlled action, but MVP persistence is limited to denied access and controlled-action evaluations; harmless reads/navigation are not persisted.';

CREATE INDEX IF NOT EXISTS ix_operator_access_evaluations__operator_time
    ON operator_console.operator_access_evaluations (operator_user_id, evaluated_at DESC);

CREATE INDEX IF NOT EXISTS ix_operator_access_evaluations__site_action_time
    ON operator_console.operator_access_evaluations (site_id, requested_action, evaluated_at DESC);

CREATE INDEX IF NOT EXISTS ix_operator_access_evaluations__device_time
    ON operator_console.operator_access_evaluations (operator_device_binding_id, evaluated_at DESC);

CREATE INDEX IF NOT EXISTS ix_operator_access_evaluations__shift_time
    ON operator_console.operator_access_evaluations (operator_shift_id, evaluated_at DESC);

CREATE INDEX IF NOT EXISTS ix_operator_access_evaluations__target_time
    ON operator_console.operator_access_evaluations (target_entity_type, target_entity_id, evaluated_at DESC)
    WHERE target_entity_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_operator_access_evaluations__correlation_id
    ON operator_console.operator_access_evaluations (correlation_id)
    WHERE correlation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_operator_access_evaluations__denied
    ON operator_console.operator_access_evaluations (evaluated_at DESC, requested_action)
    WHERE evaluation_status = 'DENIED';

CREATE TABLE IF NOT EXISTS operator_console.operator_access_evaluation_reasons (
    operator_access_evaluation_reason_id uuid DEFAULT gen_random_uuid() NOT NULL,
    operator_access_evaluation_id uuid NOT NULL,
    reason_code varchar(96) NOT NULL,
    reason_message text,
    reason_source varchar(96),
    source_entity_type varchar(64),
    source_entity_id uuid,
    evaluated_fact_path varchar(256),
    display_order integer DEFAULT 0 NOT NULL,
    created_at timestamptz DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    CONSTRAINT pk_operator_access_evaluation_reasons PRIMARY KEY (operator_access_evaluation_reason_id),
    CONSTRAINT fk_operator_access_evaluation_reasons__evaluation_id FOREIGN KEY (operator_access_evaluation_id)
        REFERENCES operator_console.operator_access_evaluations(operator_access_evaluation_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_access_evaluation_reasons__created_by_user_id FOREIGN KEY (created_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_op_access_eval_reasons__created_svc_identity FOREIGN KEY (created_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT ck_op_access_eval_reasons__display_order_nonneg CHECK (display_order >= 0)
);

COMMENT ON TABLE operator_console.operator_access_evaluation_reasons IS
    'Normalized controlled reason rows for denied or controlled-action access evaluations, with source context for audit and reporting.';

CREATE INDEX IF NOT EXISTS ix_operator_access_evaluation_reasons__evaluation_order
    ON operator_console.operator_access_evaluation_reasons (operator_access_evaluation_id, display_order);

CREATE INDEX IF NOT EXISTS ix_operator_access_evaluation_reasons__reason_time
    ON operator_console.operator_access_evaluation_reasons (reason_code, created_at DESC);

CREATE INDEX IF NOT EXISTS ix_operator_access_evaluation_reasons__source
    ON operator_console.operator_access_evaluation_reasons (reason_source, source_entity_type, source_entity_id)
    WHERE reason_source IS NOT NULL;

CREATE TABLE IF NOT EXISTS discounts.statutory_entitlement_fingerprints (
    statutory_entitlement_fingerprint_id uuid DEFAULT gen_random_uuid() NOT NULL,
    statutory_discount_validation_id uuid NOT NULL,
    entitlement_type discounts.statutory_entitlement_type_enum NOT NULL,
    fingerprint_hash char(64) NOT NULL,
    fingerprint_algorithm varchar(64) NOT NULL,
    fingerprint_algorithm_version varchar(32) NOT NULL,
    salt_reference varchar(256) NOT NULL,
    source_metadata_level varchar(64) NOT NULL,
    duplicate_detection_scope varchar(64) NOT NULL,
    matched_existing_fingerprint_id uuid,
    fingerprint_status discounts.entitlement_fingerprint_status_enum NOT NULL,
    generated_at timestamptz NOT NULL,
    generated_by_service_identity_id uuid NOT NULL,
    retention_policy_code varchar(64) NOT NULL,
    purged_at timestamptz,
    correlation_id uuid,
    created_at timestamptz DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamptz DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT pk_statutory_entitlement_fingerprints PRIMARY KEY (statutory_entitlement_fingerprint_id),
    CONSTRAINT fk_statutory_entitlement_fingerprints__validation_id FOREIGN KEY (statutory_discount_validation_id)
        REFERENCES discounts.statutory_discount_validations(statutory_discount_validation_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_statutory_entitlement_fingerprints__matched_existing_id FOREIGN KEY (matched_existing_fingerprint_id)
        REFERENCES discounts.statutory_entitlement_fingerprints(statutory_entitlement_fingerprint_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_stat_ent_fps__generated_svc_identity FOREIGN KEY (generated_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_statutory_entitlement_fingerprints__created_by_user_id FOREIGN KEY (created_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_stat_ent_fps__created_svc_identity FOREIGN KEY (created_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_statutory_entitlement_fingerprints__updated_by_user_id FOREIGN KEY (updated_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_stat_ent_fps__updated_svc_identity FOREIGN KEY (updated_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT ck_statutory_entitlement_fingerprints__row_version_positive CHECK (row_version > 0)
);

COMMENT ON TABLE discounts.statutory_entitlement_fingerprints IS
    'Duplicate-detection fingerprints for statutory entitlement validation without raw personal data.';

COMMENT ON COLUMN discounts.statutory_entitlement_fingerprints.fingerprint_hash IS
    'Stable hash used for duplicate detection. Do not store raw statutory ID numbers, birth dates, or unmasked identity values.';

COMMENT ON COLUMN discounts.statutory_entitlement_fingerprints.salt_reference IS
    'Reference to salt/pepper material only; never store secret values in this table.';

COMMENT ON COLUMN discounts.statutory_entitlement_fingerprints.duplicate_detection_scope IS
    'Controlled-code value, not a PostgreSQL enum. Initial family: OPERATOR_CONSOLE_DUPLICATE_DETECTION_SCOPE.';

CREATE INDEX IF NOT EXISTS ix_statutory_entitlement_fingerprints__validation
    ON discounts.statutory_entitlement_fingerprints (statutory_discount_validation_id);

CREATE INDEX IF NOT EXISTS ix_statutory_entitlement_fingerprints__duplicate_detection
    ON discounts.statutory_entitlement_fingerprints (
        entitlement_type,
        duplicate_detection_scope,
        fingerprint_hash
    )
    WHERE fingerprint_status = 'ACTIVE';

CREATE INDEX IF NOT EXISTS ix_statutory_entitlement_fingerprints__matched_existing
    ON discounts.statutory_entitlement_fingerprints (matched_existing_fingerprint_id)
    WHERE matched_existing_fingerprint_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_statutory_entitlement_fingerprints__correlation_id
    ON discounts.statutory_entitlement_fingerprints (correlation_id)
    WHERE correlation_id IS NOT NULL;

INSERT INTO config.controlled_code_sets (
    code_set_name,
    code_value,
    code_label,
    code_description,
    code_domain,
    code_status,
    sort_order,
    requires_comment,
    requires_approval,
    is_sensitive,
    effective_from
)
VALUES
    ('OPERATOR_CONSOLE_DUPLICATE_DETECTION_SCOPE', 'SAME_SESSION_ONLY', 'Same Session Only', 'Duplicate detection is scoped to the same parking session.', 'OPERATOR_CONSOLE', 'ACTIVE', 10, false, false, false, '2026-01-01T00:00:00Z'),
    ('OPERATOR_CONSOLE_DUPLICATE_DETECTION_SCOPE', 'SAME_SITE_ACTIVE_DAY', 'Same Site Active Day', 'Duplicate detection is scoped to the same site and active business day.', 'OPERATOR_CONSOLE', 'ACTIVE', 20, false, false, false, '2026-01-01T00:00:00Z'),
    ('OPERATOR_CONSOLE_DUPLICATE_DETECTION_SCOPE', 'SAME_SITE_GROUP_ACTIVE_DAY', 'Same Site Group Active Day', 'Duplicate detection is scoped to the same site group and active business day.', 'OPERATOR_CONSOLE', 'ACTIVE', 30, false, false, false, '2026-01-01T00:00:00Z'),
    ('OPERATOR_CONSOLE_DUPLICATE_DETECTION_SCOPE', 'GLOBAL_ACTIVE_DAY', 'Global Active Day', 'Duplicate detection is scoped globally for the active business day.', 'OPERATOR_CONSOLE', 'ACTIVE', 40, false, false, false, '2026-01-01T00:00:00Z'),
    ('OPERATOR_CONSOLE_DUPLICATE_DETECTION_SCOPE', 'CONFIGURED_POLICY_WINDOW', 'Configured Policy Window', 'Duplicate detection is scoped by configured statutory discount policy window.', 'OPERATOR_CONSOLE', 'ACTIVE', 50, false, false, false, '2026-01-01T00:00:00Z')
ON CONFLICT ON CONSTRAINT uq_controlled_code_sets__set_value_domain
DO UPDATE SET
    code_label = EXCLUDED.code_label,
    code_description = EXCLUDED.code_description,
    code_status = EXCLUDED.code_status,
    sort_order = EXCLUDED.sort_order,
    requires_comment = EXCLUDED.requires_comment,
    requires_approval = EXCLUDED.requires_approval,
    is_sensitive = EXCLUDED.is_sensitive,
    updated_at = now(),
    row_version = config.controlled_code_sets.row_version + 1;


-- ============================================================================
-- Promoted source patch: D:\SourceCodes\ExitPass\infra\db\patches\ExitPass_StatutoryDiscountPayableBasisApplicationSchema_v1.2.sql
-- ============================================================================

/*
 * ExitPass v1.2 durable SQL patch.
 *
 * Statutory discount payable-basis application schema support.
 *
 * References:
 * - docs/operator-console/statutory-discount-payable-basis-application-design.md
 *
 * System invariants:
 * - Approved Operator Console statutory discount validations may be applied to payable basis only by a future backend routine.
 * - Application evidence is stored separately from statutory validation decision state.
 * - The original tariff snapshot remains immutable; a future implementation should create a superseding tariff snapshot.
 * - This patch does not create payment attempts, payment confirmations, provider outcomes, exit authorizations,
 *   gate consumptions, coupon applications, settlement truth, reconciliation records, or AUB objects.
 */

DO $$ BEGIN
    CREATE TYPE discounts.statutory_discount_payable_application_status_enum AS ENUM (
        'REQUESTED',
        'APPLIED',
        'FAILED',
        'CANCELLED'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE discounts.statutory_discount_payable_application_channel_enum AS ENUM (
        'OPERATOR_CONSOLE',
        'OPERATOR_ASSISTED',
        'SYSTEM'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS discounts.statutory_discount_payable_basis_applications (
    statutory_discount_payable_basis_application_id uuid DEFAULT gen_random_uuid() NOT NULL,
    statutory_discount_validation_id uuid NOT NULL,
    parking_session_id uuid NOT NULL,
    original_tariff_snapshot_id uuid NOT NULL,
    applied_tariff_snapshot_id uuid,
    application_status discounts.statutory_discount_payable_application_status_enum NOT NULL,
    application_channel discounts.statutory_discount_payable_application_channel_enum NOT NULL,
    gross_amount_minor_units bigint NOT NULL,
    vat_amount_minor_units bigint NOT NULL,
    vat_exclusive_amount_minor_units bigint NOT NULL,
    statutory_discount_amount_minor_units bigint NOT NULL,
    final_payable_amount_minor_units bigint NOT NULL,
    currency_code char(3) NOT NULL,
    computation_basis_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    rounding_mode varchar(64) DEFAULT 'HALF_AWAY_FROM_ZERO' NOT NULL,
    applied_at timestamptz,
    applied_by_user_id uuid,
    applied_by_service_identity_id uuid,
    idempotency_key varchar(128),
    correlation_id uuid NOT NULL,
    created_at timestamptz DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamptz DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT pk_statutory_discount_payable_basis_applications
        PRIMARY KEY (statutory_discount_payable_basis_application_id),
    CONSTRAINT fk_sd_pba__validation
        FOREIGN KEY (statutory_discount_validation_id)
        REFERENCES discounts.statutory_discount_validations(statutory_discount_validation_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_sd_pba__parking_session
        FOREIGN KEY (parking_session_id)
        REFERENCES core.parking_sessions(parking_session_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_sd_pba__original_tariff_snapshot
        FOREIGN KEY (original_tariff_snapshot_id)
        REFERENCES core.tariff_snapshots(tariff_snapshot_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_sd_pba__applied_tariff_snapshot
        FOREIGN KEY (applied_tariff_snapshot_id)
        REFERENCES core.tariff_snapshots(tariff_snapshot_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_sd_pba__applied_by_user
        FOREIGN KEY (applied_by_user_id)
        REFERENCES identity.users(user_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_sd_pba__applied_by_service_identity
        FOREIGN KEY (applied_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_sd_pba__created_by_user
        FOREIGN KEY (created_by_user_id)
        REFERENCES identity.users(user_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_sd_pba__created_by_service_identity
        FOREIGN KEY (created_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_sd_pba__updated_by_user
        FOREIGN KEY (updated_by_user_id)
        REFERENCES identity.users(user_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_sd_pba__updated_by_service_identity
        FOREIGN KEY (updated_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT ck_sd_pba__gross_non_negative
        CHECK (gross_amount_minor_units >= 0),
    CONSTRAINT ck_sd_pba__vat_non_negative
        CHECK (vat_amount_minor_units >= 0),
    CONSTRAINT ck_sd_pba__vat_exclusive_non_negative
        CHECK (vat_exclusive_amount_minor_units >= 0),
    CONSTRAINT ck_sd_pba__discount_non_negative
        CHECK (statutory_discount_amount_minor_units >= 0),
    CONSTRAINT ck_sd_pba__final_non_negative
        CHECK (final_payable_amount_minor_units >= 0),
    CONSTRAINT ck_sd_pba__gross_components
        CHECK (vat_exclusive_amount_minor_units + vat_amount_minor_units = gross_amount_minor_units),
    CONSTRAINT ck_sd_pba__final_not_greater_than_gross
        CHECK (final_payable_amount_minor_units <= gross_amount_minor_units),
    CONSTRAINT ck_sd_pba__discount_not_greater_than_vat_exclusive
        CHECK (statutory_discount_amount_minor_units <= vat_exclusive_amount_minor_units),
    CONSTRAINT ck_sd_pba__currency_code
        CHECK (currency_code = upper(currency_code) AND currency_code ~ '^[A-Z]{3}$'),
    CONSTRAINT ck_sd_pba__applied_fields
        CHECK (
            application_status <> 'APPLIED'
            OR (applied_tariff_snapshot_id IS NOT NULL AND applied_at IS NOT NULL)
        ),
    CONSTRAINT ck_sd_pba__distinct_snapshots
        CHECK (applied_tariff_snapshot_id IS NULL OR applied_tariff_snapshot_id <> original_tariff_snapshot_id),
    CONSTRAINT ck_sd_pba__row_version_positive
        CHECK (row_version > 0)
);

COMMENT ON TABLE discounts.statutory_discount_payable_basis_applications IS
    'Immutable audit/control record for applying an approved statutory discount validation to a superseding payable-basis tariff snapshot.';

COMMENT ON COLUMN discounts.statutory_discount_payable_basis_applications.statutory_discount_validation_id IS
    'Approved discounts.statutory_discount_validations row that authorizes the payable-basis application.';

COMMENT ON COLUMN discounts.statutory_discount_payable_basis_applications.original_tariff_snapshot_id IS
    'Original active tariff snapshot used as the immutable input basis before statutory discount application.';

COMMENT ON COLUMN discounts.statutory_discount_payable_basis_applications.applied_tariff_snapshot_id IS
    'Superseding tariff snapshot created by the future apply-payable-basis implementation.';

COMMENT ON COLUMN discounts.statutory_discount_payable_basis_applications.computation_basis_json IS
    'Structured non-sensitive computation metadata such as VAT rate, source policy, formula version, and rounding inputs.';

COMMENT ON COLUMN discounts.statutory_discount_payable_basis_applications.idempotency_key IS
    'Caller-provided idempotency key for deterministic replay of payable-basis application.';

CREATE UNIQUE INDEX IF NOT EXISTS ux_sd_pba__validation_active
    ON discounts.statutory_discount_payable_basis_applications (statutory_discount_validation_id)
    WHERE application_status IN (
        'REQUESTED'::discounts.statutory_discount_payable_application_status_enum,
        'APPLIED'::discounts.statutory_discount_payable_application_status_enum
    );

CREATE UNIQUE INDEX IF NOT EXISTS ux_sd_pba__session_active
    ON discounts.statutory_discount_payable_basis_applications (parking_session_id)
    WHERE application_status IN (
        'REQUESTED'::discounts.statutory_discount_payable_application_status_enum,
        'APPLIED'::discounts.statutory_discount_payable_application_status_enum
    );

CREATE UNIQUE INDEX IF NOT EXISTS ux_sd_pba__applied_tariff_snapshot
    ON discounts.statutory_discount_payable_basis_applications (applied_tariff_snapshot_id)
    WHERE applied_tariff_snapshot_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_sd_pba__idempotency_key
    ON discounts.statutory_discount_payable_basis_applications (idempotency_key)
    WHERE idempotency_key IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_sd_pba__parking_session
    ON discounts.statutory_discount_payable_basis_applications (parking_session_id);

CREATE INDEX IF NOT EXISTS ix_sd_pba__original_tariff_snapshot
    ON discounts.statutory_discount_payable_basis_applications (original_tariff_snapshot_id);

CREATE INDEX IF NOT EXISTS ix_sd_pba__status
    ON discounts.statutory_discount_payable_basis_applications (application_status);

CREATE INDEX IF NOT EXISTS ix_sd_pba__correlation_id
    ON discounts.statutory_discount_payable_basis_applications (correlation_id);

CREATE OR REPLACE FUNCTION discounts.enforce_statutory_discount_payable_basis_application()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
DECLARE
    v_validation discounts.statutory_discount_validations%ROWTYPE;
    v_original_tariff core.tariff_snapshots%ROWTYPE;
    v_applied_tariff core.tariff_snapshots%ROWTYPE;
    v_payment_attempt_exists boolean;
BEGIN
    SELECT *
    INTO v_validation
    FROM discounts.statutory_discount_validations
    WHERE statutory_discount_validation_id = NEW.statutory_discount_validation_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'statutory discount validation % was not found', NEW.statutory_discount_validation_id
            USING ERRCODE = '23503';
    END IF;

    IF v_validation.parking_session_id <> NEW.parking_session_id THEN
        RAISE EXCEPTION 'statutory discount validation % belongs to parking session %, not %',
            NEW.statutory_discount_validation_id,
            v_validation.parking_session_id,
            NEW.parking_session_id
            USING ERRCODE = '23514';
    END IF;

    SELECT *
    INTO v_original_tariff
    FROM core.tariff_snapshots
    WHERE tariff_snapshot_id = NEW.original_tariff_snapshot_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'original tariff snapshot % was not found', NEW.original_tariff_snapshot_id
            USING ERRCODE = '23503';
    END IF;

    IF v_original_tariff.parking_session_id <> NEW.parking_session_id THEN
        RAISE EXCEPTION 'original tariff snapshot % belongs to parking session %, not %',
            NEW.original_tariff_snapshot_id,
            v_original_tariff.parking_session_id,
            NEW.parking_session_id
            USING ERRCODE = '23514';
    END IF;

    IF NEW.application_status = 'APPLIED' THEN
        IF v_validation.validation_status <> 'APPROVED' THEN
            RAISE EXCEPTION 'statutory discount validation % must be APPROVED before payable-basis application',
                NEW.statutory_discount_validation_id
                USING ERRCODE = '23514';
        END IF;

        IF v_validation.evidence_required AND NOT v_validation.evidence_captured THEN
            RAISE EXCEPTION 'statutory discount validation % requires captured evidence before payable-basis application',
                NEW.statutory_discount_validation_id
                USING ERRCODE = '23514';
        END IF;

        SELECT *
        INTO v_applied_tariff
        FROM core.tariff_snapshots
        WHERE tariff_snapshot_id = NEW.applied_tariff_snapshot_id;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'applied tariff snapshot % was not found', NEW.applied_tariff_snapshot_id
                USING ERRCODE = '23503';
        END IF;

        IF v_applied_tariff.parking_session_id <> NEW.parking_session_id THEN
            RAISE EXCEPTION 'applied tariff snapshot % belongs to parking session %, not %',
                NEW.applied_tariff_snapshot_id,
                v_applied_tariff.parking_session_id,
                NEW.parking_session_id
                USING ERRCODE = '23514';
        END IF;

        IF v_applied_tariff.statutory_discount_validation_id IS DISTINCT FROM NEW.statutory_discount_validation_id THEN
            RAISE EXCEPTION 'applied tariff snapshot % must reference statutory discount validation %',
                NEW.applied_tariff_snapshot_id,
                NEW.statutory_discount_validation_id
                USING ERRCODE = '23514';
        END IF;

        IF v_applied_tariff.snapshot_status <> 'ACTIVE' THEN
            RAISE EXCEPTION 'applied tariff snapshot % must be ACTIVE, not %',
                NEW.applied_tariff_snapshot_id,
                v_applied_tariff.snapshot_status
                USING ERRCODE = '23514';
        END IF;

        IF v_applied_tariff.statutory_discount_amount <= 0 THEN
            RAISE EXCEPTION 'applied tariff snapshot % must contain a positive statutory discount amount',
                NEW.applied_tariff_snapshot_id
                USING ERRCODE = '23514';
        END IF;

        SELECT EXISTS (
            SELECT 1
            FROM core.payment_attempts
            WHERE parking_session_id = NEW.parking_session_id
        )
        INTO v_payment_attempt_exists;

        IF v_payment_attempt_exists THEN
            RAISE EXCEPTION 'parking session % already has a payment attempt and cannot receive statutory payable-basis application',
                NEW.parking_session_id
                USING ERRCODE = '23514';
        END IF;
    END IF;

    RETURN NEW;
END;
$function$;

DROP TRIGGER IF EXISTS trg_sd_pba__enforce
    ON discounts.statutory_discount_payable_basis_applications;

CREATE TRIGGER trg_sd_pba__enforce
BEFORE INSERT OR UPDATE OF
    statutory_discount_validation_id,
    parking_session_id,
    original_tariff_snapshot_id,
    applied_tariff_snapshot_id,
    application_status
ON discounts.statutory_discount_payable_basis_applications
FOR EACH ROW
EXECUTE FUNCTION discounts.enforce_statutory_discount_payable_basis_application();


-- ============================================================================
-- Promoted source patch: D:\SourceCodes\ExitPass\infra\db\patches\ExitPass_StatutoryDiscountAppliedTariffSnapshotLifecycle_v1.2.sql
-- ============================================================================

/*
 * ExitPass v1.2 durable SQL patch.
 *
 * Statutory discount final APPLIED tariff snapshot lifecycle support.
 *
 * References:
 * - docs/operator-console/statutory-discount-applied-tariff-snapshot-lifecycle-design.md
 * - docs/operator-console/statutory-discount-payable-basis-application-design.md
 *
 * System invariants:
 * - The original tariff snapshot amount fields are not mutated by this routine.
 * - The original tariff snapshot may transition from ACTIVE to SUPERSEDED as lifecycle metadata only.
 * - The applied statutory discount payable basis is represented by one new ACTIVE tariff snapshot.
 * - The payable-basis application row is the durable idempotency/audit anchor.
 * - This patch does not create payment attempts, payment confirmations, provider outcomes, exit authorizations,
 *   gate consumptions, coupon applications, settlement truth, reconciliation records, or AUB objects.
 */

CREATE UNIQUE INDEX IF NOT EXISTS ux_tariff_snapshots__statutory_discount_validation_applied
    ON core.tariff_snapshots (statutory_discount_validation_id)
    WHERE statutory_discount_validation_id IS NOT NULL;

COMMENT ON INDEX core.ux_tariff_snapshots__statutory_discount_validation_applied IS
    'Ensures one statutory-discount-adjusted tariff snapshot per statutory discount validation.';

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint con
        JOIN pg_class cls ON cls.oid = con.conrelid
        JOIN pg_namespace n ON n.oid = cls.relnamespace
        WHERE n.nspname = 'core'
          AND cls.relname = 'tariff_snapshots'
          AND con.conname = 'ck_tariff_snapshots__statutory_discount_link_has_discount'
    ) THEN
        ALTER TABLE core.tariff_snapshots
            ADD CONSTRAINT ck_tariff_snapshots__statutory_discount_link_has_discount
            CHECK (
                statutory_discount_validation_id IS NULL
                OR statutory_discount_amount > 0
            );
    END IF;
END $$;

COMMENT ON CONSTRAINT ck_tariff_snapshots__statutory_discount_link_has_discount
    ON core.tariff_snapshots IS
    'A tariff snapshot linked to a statutory discount validation must carry a positive statutory discount amount.';

CREATE OR REPLACE FUNCTION discounts.apply_statutory_discount_payable_basis(
    p_statutory_discount_payable_basis_application_id uuid,
    p_actor_user_id uuid,
    p_correlation_id uuid
)
RETURNS TABLE (
    statutory_discount_payable_basis_application_id uuid,
    statutory_discount_validation_id uuid,
    parking_session_id uuid,
    original_tariff_snapshot_id uuid,
    applied_tariff_snapshot_id uuid,
    application_status text,
    previous_tariff_snapshot_status text,
    applied_tariff_snapshot_status text,
    final_payable_amount_minor_units bigint,
    currency_code text,
    already_applied boolean,
    outcome_code text,
    failure_code text
)
LANGUAGE plpgsql
AS $function$
DECLARE
    v_now timestamptz := now();
    v_application discounts.statutory_discount_payable_basis_applications%ROWTYPE;
    v_validation discounts.statutory_discount_validations%ROWTYPE;
    v_session core.parking_sessions%ROWTYPE;
    v_original_tariff core.tariff_snapshots%ROWTYPE;
    v_applied_tariff core.tariff_snapshots%ROWTYPE;
    v_applied_tariff_snapshot_id uuid;
    v_payment_attempt_exists boolean;
BEGIN
    SET CONSTRAINTS ALL DEFERRED;

    SELECT app.*
    INTO v_application
    FROM discounts.statutory_discount_payable_basis_applications AS app
    WHERE app.statutory_discount_payable_basis_application_id = p_statutory_discount_payable_basis_application_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            p_statutory_discount_payable_basis_application_id,
            NULL::uuid,
            NULL::uuid,
            NULL::uuid,
            NULL::uuid,
            NULL::text,
            NULL::text,
            NULL::text,
            NULL::bigint,
            NULL::text,
            FALSE,
            'PAYABLE_BASIS_APPLICATION_NOT_FOUND'::text,
            'PAYABLE_BASIS_APPLICATION_NOT_FOUND'::text;
        RETURN;
    END IF;

    IF v_application.application_status = 'APPLIED'
       AND v_application.applied_tariff_snapshot_id IS NOT NULL THEN
        SELECT ts.*
        INTO v_original_tariff
        FROM core.tariff_snapshots AS ts
        WHERE ts.tariff_snapshot_id = v_application.original_tariff_snapshot_id;

        SELECT ts.*
        INTO v_applied_tariff
        FROM core.tariff_snapshots AS ts
        WHERE ts.tariff_snapshot_id = v_application.applied_tariff_snapshot_id;

        RETURN QUERY
        SELECT
            v_application.statutory_discount_payable_basis_application_id,
            v_application.statutory_discount_validation_id,
            v_application.parking_session_id,
            v_application.original_tariff_snapshot_id,
            v_application.applied_tariff_snapshot_id,
            v_application.application_status::text,
            CASE WHEN v_original_tariff.tariff_snapshot_id IS NULL THEN NULL ELSE v_original_tariff.snapshot_status::text END,
            CASE WHEN v_applied_tariff.tariff_snapshot_id IS NULL THEN NULL ELSE v_applied_tariff.snapshot_status::text END,
            v_application.final_payable_amount_minor_units,
            v_application.currency_code::text,
            TRUE,
            'ALREADY_APPLIED'::text,
            NULL::text;
        RETURN;
    END IF;

    IF v_application.application_status <> 'REQUESTED' THEN
        RETURN QUERY
        SELECT
            v_application.statutory_discount_payable_basis_application_id,
            v_application.statutory_discount_validation_id,
            v_application.parking_session_id,
            v_application.original_tariff_snapshot_id,
            v_application.applied_tariff_snapshot_id,
            v_application.application_status::text,
            NULL::text,
            NULL::text,
            v_application.final_payable_amount_minor_units,
            v_application.currency_code::text,
            FALSE,
            'PAYABLE_BASIS_APPLICATION_NOT_REQUESTED'::text,
            'PAYABLE_BASIS_APPLICATION_NOT_REQUESTED'::text;
        RETURN;
    END IF;

    SELECT sdv.*
    INTO v_validation
    FROM discounts.statutory_discount_validations AS sdv
    WHERE sdv.statutory_discount_validation_id = v_application.statutory_discount_validation_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            v_application.statutory_discount_payable_basis_application_id,
            v_application.statutory_discount_validation_id,
            v_application.parking_session_id,
            v_application.original_tariff_snapshot_id,
            NULL::uuid,
            v_application.application_status::text,
            NULL::text,
            NULL::text,
            v_application.final_payable_amount_minor_units,
            v_application.currency_code::text,
            FALSE,
            'STATUTORY_DISCOUNT_VALIDATION_NOT_FOUND'::text,
            'STATUTORY_DISCOUNT_VALIDATION_NOT_FOUND'::text;
        RETURN;
    END IF;

    IF v_validation.validation_status <> 'APPROVED' THEN
        RETURN QUERY
        SELECT
            v_application.statutory_discount_payable_basis_application_id,
            v_application.statutory_discount_validation_id,
            v_application.parking_session_id,
            v_application.original_tariff_snapshot_id,
            NULL::uuid,
            v_application.application_status::text,
            NULL::text,
            NULL::text,
            v_application.final_payable_amount_minor_units,
            v_application.currency_code::text,
            FALSE,
            'STATUTORY_DISCOUNT_NOT_APPROVED'::text,
            'STATUTORY_DISCOUNT_NOT_APPROVED'::text;
        RETURN;
    END IF;

    IF v_validation.evidence_required AND NOT v_validation.evidence_captured THEN
        RETURN QUERY
        SELECT
            v_application.statutory_discount_payable_basis_application_id,
            v_application.statutory_discount_validation_id,
            v_application.parking_session_id,
            v_application.original_tariff_snapshot_id,
            NULL::uuid,
            v_application.application_status::text,
            NULL::text,
            NULL::text,
            v_application.final_payable_amount_minor_units,
            v_application.currency_code::text,
            FALSE,
            'EVIDENCE_REQUIRED_NOT_CAPTURED'::text,
            'EVIDENCE_REQUIRED_NOT_CAPTURED'::text;
        RETURN;
    END IF;

    SELECT ps.*
    INTO v_session
    FROM core.parking_sessions AS ps
    WHERE ps.parking_session_id = v_application.parking_session_id
    FOR UPDATE;

    IF NOT FOUND OR v_session.session_status <> 'ACTIVE' THEN
        RETURN QUERY
        SELECT
            v_application.statutory_discount_payable_basis_application_id,
            v_application.statutory_discount_validation_id,
            v_application.parking_session_id,
            v_application.original_tariff_snapshot_id,
            NULL::uuid,
            v_application.application_status::text,
            NULL::text,
            NULL::text,
            v_application.final_payable_amount_minor_units,
            v_application.currency_code::text,
            FALSE,
            'SESSION_NOT_ELIGIBLE'::text,
            'SESSION_NOT_ELIGIBLE'::text;
        RETURN;
    END IF;

    IF v_validation.parking_session_id <> v_application.parking_session_id THEN
        RETURN QUERY
        SELECT
            v_application.statutory_discount_payable_basis_application_id,
            v_application.statutory_discount_validation_id,
            v_application.parking_session_id,
            v_application.original_tariff_snapshot_id,
            NULL::uuid,
            v_application.application_status::text,
            NULL::text,
            NULL::text,
            v_application.final_payable_amount_minor_units,
            v_application.currency_code::text,
            FALSE,
            'PAYABLE_BASIS_APPLICATION_FAILED'::text,
            'PAYABLE_BASIS_APPLICATION_FAILED'::text;
        RETURN;
    END IF;

    SELECT ts.*
    INTO v_original_tariff
    FROM core.tariff_snapshots AS ts
    WHERE ts.tariff_snapshot_id = v_application.original_tariff_snapshot_id
    FOR UPDATE;

    IF NOT FOUND OR v_original_tariff.parking_session_id <> v_application.parking_session_id THEN
        RETURN QUERY
        SELECT
            v_application.statutory_discount_payable_basis_application_id,
            v_application.statutory_discount_validation_id,
            v_application.parking_session_id,
            v_application.original_tariff_snapshot_id,
            NULL::uuid,
            v_application.application_status::text,
            NULL::text,
            NULL::text,
            v_application.final_payable_amount_minor_units,
            v_application.currency_code::text,
            FALSE,
            'TARIFF_SNAPSHOT_NOT_FOUND'::text,
            'TARIFF_SNAPSHOT_NOT_FOUND'::text;
        RETURN;
    END IF;

    IF v_original_tariff.snapshot_status <> 'ACTIVE'
       OR v_original_tariff.consumed_at IS NOT NULL
       OR v_original_tariff.superseded_by_tariff_snapshot_id IS NOT NULL
       OR v_original_tariff.expires_at <= v_now THEN
        RETURN QUERY
        SELECT
            v_application.statutory_discount_payable_basis_application_id,
            v_application.statutory_discount_validation_id,
            v_application.parking_session_id,
            v_application.original_tariff_snapshot_id,
            NULL::uuid,
            v_application.application_status::text,
            v_original_tariff.snapshot_status::text,
            NULL::text,
            v_application.final_payable_amount_minor_units,
            v_application.currency_code::text,
            FALSE,
            'TARIFF_SNAPSHOT_NOT_ELIGIBLE'::text,
            'TARIFF_SNAPSHOT_NOT_ELIGIBLE'::text;
        RETURN;
    END IF;

    SELECT EXISTS (
        SELECT 1
        FROM core.payment_attempts AS pa
        WHERE pa.parking_session_id = v_application.parking_session_id
           OR pa.tariff_snapshot_id = v_application.original_tariff_snapshot_id
    )
    INTO v_payment_attempt_exists;

    IF v_payment_attempt_exists THEN
        RETURN QUERY
        SELECT
            v_application.statutory_discount_payable_basis_application_id,
            v_application.statutory_discount_validation_id,
            v_application.parking_session_id,
            v_application.original_tariff_snapshot_id,
            NULL::uuid,
            v_application.application_status::text,
            v_original_tariff.snapshot_status::text,
            NULL::text,
            v_application.final_payable_amount_minor_units,
            v_application.currency_code::text,
            FALSE,
            'PAYMENT_ATTEMPT_ALREADY_EXISTS'::text,
            'PAYMENT_ATTEMPT_ALREADY_EXISTS'::text;
        RETURN;
    END IF;

    v_applied_tariff_snapshot_id := gen_random_uuid();

    UPDATE core.tariff_snapshots AS original
    SET snapshot_status = 'SUPERSEDED',
        superseded_by_tariff_snapshot_id = v_applied_tariff_snapshot_id,
        updated_at = v_now,
        updated_by_service_identity_id = COALESCE(
            v_original_tariff.updated_by_service_identity_id,
            v_original_tariff.created_by_service_identity_id
        ),
        row_version = original.row_version + 1
    WHERE original.tariff_snapshot_id = v_original_tariff.tariff_snapshot_id;

    INSERT INTO core.tariff_snapshots (
        tariff_snapshot_id,
        parking_session_id,
        vendor_system_id,
        vendor_tariff_ref,
        tariff_version_reference,
        currency_code,
        gross_amount,
        statutory_discount_amount,
        coupon_discount_amount,
        net_amount,
        statutory_discount_validation_id,
        coupon_application_id,
        snapshot_status,
        calculated_at,
        expires_at,
        consumed_at,
        correlation_id,
        created_at,
        created_by_service_identity_id,
        updated_at,
        updated_by_service_identity_id,
        row_version
    )
    VALUES (
        v_applied_tariff_snapshot_id,
        v_original_tariff.parking_session_id,
        v_original_tariff.vendor_system_id,
        v_original_tariff.vendor_tariff_ref,
        CASE
            WHEN v_original_tariff.tariff_version_reference IS NULL THEN 'STATUTORY_DISCOUNT_APPLIED'
            ELSE v_original_tariff.tariff_version_reference || '|STATUTORY_DISCOUNT_APPLIED'
        END,
        v_application.currency_code,
        (v_application.gross_amount_minor_units::numeric / 100),
        (v_application.statutory_discount_amount_minor_units::numeric / 100),
        0,
        (v_application.final_payable_amount_minor_units::numeric / 100),
        v_application.statutory_discount_validation_id,
        NULL,
        'ACTIVE',
        v_now,
        v_original_tariff.expires_at,
        NULL,
        COALESCE(p_correlation_id, v_application.correlation_id),
        v_now,
        v_original_tariff.created_by_service_identity_id,
        v_now,
        COALESCE(v_original_tariff.updated_by_service_identity_id, v_original_tariff.created_by_service_identity_id),
        1
    );

    UPDATE discounts.statutory_discount_validations AS sdv
    SET tariff_snapshot_id = v_applied_tariff_snapshot_id,
        currency_code = v_application.currency_code,
        gross_amount_at_validation = (v_application.gross_amount_minor_units::numeric / 100),
        statutory_discount_amount = (v_application.statutory_discount_amount_minor_units::numeric / 100),
        net_amount_after_discount = (v_application.final_payable_amount_minor_units::numeric / 100),
        updated_at = v_now,
        updated_by_user_id = p_actor_user_id,
        row_version = sdv.row_version + 1
    WHERE sdv.statutory_discount_validation_id = v_application.statutory_discount_validation_id;

    UPDATE discounts.statutory_discount_payable_basis_applications AS app
    SET applied_tariff_snapshot_id = v_applied_tariff_snapshot_id,
        application_status = 'APPLIED',
        applied_at = v_now,
        applied_by_user_id = p_actor_user_id,
        correlation_id = COALESCE(p_correlation_id, app.correlation_id),
        updated_at = v_now,
        updated_by_user_id = p_actor_user_id,
        row_version = app.row_version + 1
    WHERE app.statutory_discount_payable_basis_application_id = v_application.statutory_discount_payable_basis_application_id
    RETURNING *
    INTO v_application;

    SELECT ts.*
    INTO v_applied_tariff
    FROM core.tariff_snapshots AS ts
    WHERE ts.tariff_snapshot_id = v_applied_tariff_snapshot_id;

    RETURN QUERY
    SELECT
        v_application.statutory_discount_payable_basis_application_id,
        v_application.statutory_discount_validation_id,
        v_application.parking_session_id,
        v_application.original_tariff_snapshot_id,
        v_application.applied_tariff_snapshot_id,
        v_application.application_status::text,
        'ACTIVE'::text,
        v_applied_tariff.snapshot_status::text,
        v_application.final_payable_amount_minor_units,
        v_application.currency_code::text,
        FALSE,
        'APPLIED'::text,
        NULL::text;
END;
$function$;

COMMENT ON FUNCTION discounts.apply_statutory_discount_payable_basis(uuid, uuid, uuid) IS
    'Finalizes a REQUESTED statutory discount payable-basis application by superseding the original active tariff snapshot, creating one statutory-adjusted ACTIVE tariff snapshot, and marking the application APPLIED. The routine does not create payment, provider, gate, coupon, reconciliation, or AUB records.';


-- ============================================================================
-- Promoted source patch: D:\SourceCodes\ExitPass\infra\db\patches\ExitPass_ProductionPolicyImportReviewQueue_v1.2.sql
-- ============================================================================

/*
 * ExitPass v1.2 durable SQL patch.
 *
 * Operator Console production policy import review queue persistence.
 *
 * System invariants:
 * - This patch creates only review queue persistence objects.
 * - Approval means APPROVED_FOR_DB_REPO_ALIGNMENT only.
 * - This patch does not import, seed, activate, or approve production policy registry rows.
 * - This patch does not create production policy import execution jobs.
 */

CREATE SCHEMA IF NOT EXISTS operator_console;

CREATE TABLE IF NOT EXISTS operator_console.production_policy_import_review_submissions (
    review_id uuid DEFAULT gen_random_uuid() NOT NULL,
    maker_operator_id uuid NOT NULL,
    file_name varchar(512),
    submission_fingerprint varchar(64) NOT NULL,
    review_status varchar(64) NOT NULL,
    dry_run_result_json jsonb NOT NULL,
    correlation_id uuid NOT NULL,
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT pk_policy_import_review_submissions PRIMARY KEY (review_id),
    CONSTRAINT ck_policy_import_review_submissions__status
        CHECK (review_status IN (
            'DRAFT_DRY_RUN',
            'SUBMITTED_FOR_REVIEW',
            'LEGAL_REVIEW_PENDING',
            'OPS_REVIEW_PENDING',
            'QA_REVIEW_PENDING',
            'DB_REVIEW_PENDING',
            'APPROVED_FOR_DB_REPO_ALIGNMENT',
            'REJECTED',
            'CANCELLED',
            'SUPERSEDED'
        )),
    CONSTRAINT ck_policy_import_review_submissions__fingerprint
        CHECK (submission_fingerprint ~ '^[0-9a-f]{64}$'),
    CONSTRAINT ck_policy_import_review_submissions__dry_run_only
        CHECK (
            COALESCE((dry_run_result_json ->> 'isDryRun')::boolean, false) = true
            AND COALESCE((dry_run_result_json ->> 'policiesImported')::boolean, true) = false
        ),
    CONSTRAINT ck_policy_import_review_submissions__row_version_positive
        CHECK (row_version > 0)
);

COMMENT ON TABLE operator_console.production_policy_import_review_submissions IS
    'DB-backed Operator Console production policy import review submissions. Approval does not import or activate policy rows.';

CREATE UNIQUE INDEX IF NOT EXISTS ux_policy_import_review_submissions__active_fingerprint
    ON operator_console.production_policy_import_review_submissions (maker_operator_id, submission_fingerprint)
    WHERE review_status NOT IN ('REJECTED', 'CANCELLED', 'SUPERSEDED');

CREATE INDEX IF NOT EXISTS ix_policy_import_review_submissions__status
    ON operator_console.production_policy_import_review_submissions (review_status, updated_at DESC);

CREATE TABLE IF NOT EXISTS operator_console.production_policy_import_review_decisions (
    review_decision_id uuid DEFAULT gen_random_uuid() NOT NULL,
    review_id uuid NOT NULL,
    reviewer_role varchar(32) NOT NULL,
    decision_action varchar(64) NOT NULL,
    reviewer_operator_id uuid NOT NULL,
    reason text,
    decided_at timestamptz DEFAULT now() NOT NULL,
    correlation_id uuid NOT NULL,
    created_at timestamptz DEFAULT now() NOT NULL,
    CONSTRAINT pk_policy_import_review_decisions PRIMARY KEY (review_decision_id),
    CONSTRAINT fk_policy_import_review_decisions__review
        FOREIGN KEY (review_id)
        REFERENCES operator_console.production_policy_import_review_submissions(review_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_policy_import_review_decisions__review_role
        UNIQUE (review_id, reviewer_role),
    CONSTRAINT ck_policy_import_review_decisions__role
        CHECK (reviewer_role IN ('LEGAL', 'OPS', 'QA', 'DB')),
    CONSTRAINT ck_policy_import_review_decisions__action
        CHECK (decision_action IN ('APPROVE_LEGAL', 'APPROVE_OPS', 'APPROVE_QA', 'APPROVE_DB')),
    CONSTRAINT ck_policy_import_review_decisions__reason
        CHECK (reason IS NULL OR btrim(reason) <> '')
);

COMMENT ON TABLE operator_console.production_policy_import_review_decisions IS
    'Per-role checker approvals for production policy import review alignment. Contains no import or activation action.';

CREATE INDEX IF NOT EXISTS ix_policy_import_review_decisions__review
    ON operator_console.production_policy_import_review_decisions (review_id, decided_at);

CREATE TABLE IF NOT EXISTS operator_console.production_policy_import_review_history (
    review_history_id uuid DEFAULT gen_random_uuid() NOT NULL,
    review_id uuid NOT NULL,
    history_fingerprint varchar(64) NOT NULL,
    decision_action varchar(64) NOT NULL,
    review_status varchar(64) NOT NULL,
    actor_operator_id uuid NOT NULL,
    reviewer_role varchar(32),
    reason text,
    occurred_at timestamptz DEFAULT now() NOT NULL,
    correlation_id uuid NOT NULL,
    created_at timestamptz DEFAULT now() NOT NULL,
    CONSTRAINT pk_policy_import_review_history PRIMARY KEY (review_history_id),
    CONSTRAINT fk_policy_import_review_history__review
        FOREIGN KEY (review_id)
        REFERENCES operator_console.production_policy_import_review_submissions(review_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_policy_import_review_history__fingerprint
        UNIQUE (review_id, history_fingerprint),
    CONSTRAINT ck_policy_import_review_history__fingerprint
        CHECK (history_fingerprint ~ '^[0-9a-f]{64}$'),
    CONSTRAINT ck_policy_import_review_history__status
        CHECK (review_status IN (
            'DRAFT_DRY_RUN',
            'SUBMITTED_FOR_REVIEW',
            'LEGAL_REVIEW_PENDING',
            'OPS_REVIEW_PENDING',
            'QA_REVIEW_PENDING',
            'DB_REVIEW_PENDING',
            'APPROVED_FOR_DB_REPO_ALIGNMENT',
            'REJECTED',
            'CANCELLED',
            'SUPERSEDED'
        )),
    CONSTRAINT ck_policy_import_review_history__action
        CHECK (decision_action IN (
            'SUBMIT_FOR_REVIEW',
            'REQUEST_CHANGES',
            'APPROVE_LEGAL',
            'APPROVE_OPS',
            'APPROVE_QA',
            'APPROVE_DB',
            'REJECT',
            'ESCALATE',
            'CANCEL',
            'MARK_SUPERSEDED'
        )),
    CONSTRAINT ck_policy_import_review_history__role
        CHECK (reviewer_role IS NULL OR reviewer_role IN ('LEGAL', 'OPS', 'QA', 'DB')),
    CONSTRAINT ck_policy_import_review_history__reason
        CHECK (reason IS NULL OR btrim(reason) <> '')
);

COMMENT ON TABLE operator_console.production_policy_import_review_history IS
    'Decision history for Operator Console production policy import review. Final approval is DB repo alignment only.';

CREATE INDEX IF NOT EXISTS ix_policy_import_review_history__review
    ON operator_console.production_policy_import_review_history (review_id, occurred_at);

CREATE TABLE IF NOT EXISTS operator_console.production_policy_import_review_findings (
    review_finding_id uuid DEFAULT gen_random_uuid() NOT NULL,
    review_id uuid NOT NULL,
    finding_fingerprint varchar(64) NOT NULL,
    severity varchar(16) NOT NULL,
    message text NOT NULL,
    field_name varchar(128),
    created_at timestamptz DEFAULT now() NOT NULL,
    CONSTRAINT pk_policy_import_review_findings PRIMARY KEY (review_finding_id),
    CONSTRAINT fk_policy_import_review_findings__review
        FOREIGN KEY (review_id)
        REFERENCES operator_console.production_policy_import_review_submissions(review_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_policy_import_review_findings__fingerprint
        UNIQUE (review_id, finding_fingerprint),
    CONSTRAINT ck_policy_import_review_findings__fingerprint
        CHECK (finding_fingerprint ~ '^[0-9a-f]{64}$'),
    CONSTRAINT ck_policy_import_review_findings__severity
        CHECK (severity IN ('PASS', 'WARN', 'FAIL')),
    CONSTRAINT ck_policy_import_review_findings__message
        CHECK (btrim(message) <> '')
);

COMMENT ON TABLE operator_console.production_policy_import_review_findings IS
    'Review-level findings generated by the production policy import review queue workflow.';

CREATE INDEX IF NOT EXISTS ix_policy_import_review_findings__review
    ON operator_console.production_policy_import_review_findings (review_id, created_at);

