CREATE INDEX IF NOT EXISTS ix_fiscal_issuance_references__upstream_finality_reference
    ON core.fiscal_issuance_references (upstream_finality_reference);;

