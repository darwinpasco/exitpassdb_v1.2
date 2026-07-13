CREATE INDEX IF NOT EXISTS ix_fiscal_issuance_references__state
    ON core.fiscal_issuance_references (fiscal_issuance_state);;

