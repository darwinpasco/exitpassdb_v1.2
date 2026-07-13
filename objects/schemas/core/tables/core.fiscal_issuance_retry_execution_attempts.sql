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
);;

