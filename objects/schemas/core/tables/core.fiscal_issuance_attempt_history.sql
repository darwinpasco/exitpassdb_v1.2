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
);;

