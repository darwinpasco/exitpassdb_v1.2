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
);;

