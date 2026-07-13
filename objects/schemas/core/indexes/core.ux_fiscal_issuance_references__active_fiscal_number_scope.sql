CREATE UNIQUE INDEX IF NOT EXISTS ux_fiscal_issuance_references__active_fiscal_number_scope
    ON core.fiscal_issuance_references (
        site_pos_server_id,
        fiscal_identity_id,
        fiscal_sequence_policy_id,
        fiscal_document_number
    )
    WHERE is_active = true
      AND site_pos_server_id IS NOT NULL
      AND fiscal_identity_id IS NOT NULL
      AND fiscal_sequence_policy_id IS NOT NULL
      AND fiscal_document_number IS NOT NULL;;

