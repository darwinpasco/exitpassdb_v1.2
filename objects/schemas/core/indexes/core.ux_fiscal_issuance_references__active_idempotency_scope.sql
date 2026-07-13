CREATE UNIQUE INDEX IF NOT EXISTS ux_fiscal_issuance_references__active_idempotency_scope
    ON core.fiscal_issuance_references (site_pos_server_id, fiscal_document_type_code_id, upstream_finality_reference)
    WHERE is_active = true
      AND site_pos_server_id IS NOT NULL
      AND fiscal_document_type_code_id IS NOT NULL;;

