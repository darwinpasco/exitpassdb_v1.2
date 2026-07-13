CREATE INDEX IF NOT EXISTS ix_fiscal_issuance_retry_schedule_preparations__reference_requested
    ON core.fiscal_issuance_retry_schedule_preparations (fiscal_issuance_reference_id, requested_at DESC);;

