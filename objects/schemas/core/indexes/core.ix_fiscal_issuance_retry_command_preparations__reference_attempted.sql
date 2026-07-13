CREATE INDEX IF NOT EXISTS ix_fiscal_issuance_retry_command_preparations__reference_attempted
    ON core.fiscal_issuance_retry_command_preparations (fiscal_issuance_reference_id, attempted_at DESC);;

