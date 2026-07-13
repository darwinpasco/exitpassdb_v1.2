CREATE INDEX IF NOT EXISTS ix_fiscal_issuance_attempt_history__payment_confirmation
    ON core.fiscal_issuance_attempt_history (payment_confirmation_id, attempted_at DESC);;

