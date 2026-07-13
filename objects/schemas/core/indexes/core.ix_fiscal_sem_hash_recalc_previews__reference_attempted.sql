CREATE INDEX IF NOT EXISTS ix_fiscal_sem_hash_recalc_previews__reference_attempted
    ON core.fiscal_issuance_semantic_hash_recalculation_previews (fiscal_issuance_reference_id, attempted_at DESC);;

