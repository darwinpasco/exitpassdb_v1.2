CREATE UNIQUE INDEX IF NOT EXISTS ux_fiscal_issuance_references__active_pos_document
    ON core.fiscal_issuance_references (pos_server_fiscal_document_id)
    WHERE is_active = true
      AND pos_server_fiscal_document_id IS NOT NULL;;

