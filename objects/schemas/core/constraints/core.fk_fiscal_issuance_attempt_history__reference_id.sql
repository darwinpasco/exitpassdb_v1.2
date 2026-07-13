ALTER TABLE core.fiscal_issuance_attempt_history
    ADD CONSTRAINT fk_fiscal_issuance_attempt_history__reference_id
    FOREIGN KEY (fiscal_issuance_reference_id)
    REFERENCES core.fiscal_issuance_references(fiscal_issuance_reference_id)
    DEFERRABLE INITIALLY IMMEDIATE;;

