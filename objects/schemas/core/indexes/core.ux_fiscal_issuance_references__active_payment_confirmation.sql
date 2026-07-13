CREATE UNIQUE INDEX IF NOT EXISTS ux_fiscal_issuance_references__active_payment_confirmation
    ON core.fiscal_issuance_references (payment_confirmation_id)
    WHERE is_active = true;;

