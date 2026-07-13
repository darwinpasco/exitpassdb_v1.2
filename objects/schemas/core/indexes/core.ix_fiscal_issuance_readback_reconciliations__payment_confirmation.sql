CREATE INDEX IF NOT EXISTS ix_fiscal_issuance_readback_reconciliations__payment_confirmation
    ON core.fiscal_issuance_readback_reconciliations (payment_confirmation_id, readback_requested_at DESC);;

