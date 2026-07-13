ALTER TABLE core.fiscal_issuance_retry_command_preparations
    ADD CONSTRAINT fk_fiscal_issuance_retry_command_preparations__reference_id
    FOREIGN KEY (fiscal_issuance_reference_id)
    REFERENCES core.fiscal_issuance_references(fiscal_issuance_reference_id)
    DEFERRABLE INITIALLY IMMEDIATE;;

