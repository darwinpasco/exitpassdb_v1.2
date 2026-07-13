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
);;

