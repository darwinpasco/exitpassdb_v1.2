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
);;

