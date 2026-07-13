CREATE INDEX IF NOT EXISTS ix_fiscal_issuance_retry_execution_attempts__reference_attempted
    ON core.fiscal_issuance_retry_execution_attempts (fiscal_issuance_reference_id, attempted_at DESC);;

