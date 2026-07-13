CREATE INDEX IF NOT EXISTS ix_fiscal_sem_hash_backfill_mutation__reference_attempted
    ON core.fiscal_issuance_semantic_hash_backfill_mutation_preparations (fiscal_issuance_reference_id, attempted_at DESC);;

