CREATE INDEX IF NOT EXISTS ix_fiscal_sem_hash_backfill_workflow__reference_requested
    ON core.fiscal_issuance_semantic_hash_backfill_workflow_requests (fiscal_issuance_reference_id, requested_at DESC);;

