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
);;

