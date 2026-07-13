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
);;

