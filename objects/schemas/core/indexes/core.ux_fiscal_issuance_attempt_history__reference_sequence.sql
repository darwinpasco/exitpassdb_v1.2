CREATE UNIQUE INDEX IF NOT EXISTS ux_fiscal_issuance_attempt_history__reference_sequence
    ON core.fiscal_issuance_attempt_history (fiscal_issuance_reference_id, attempt_sequence_number)
    WHERE fiscal_issuance_reference_id IS NOT NULL;;

