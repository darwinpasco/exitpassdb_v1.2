ALTER TABLE core.fiscal_issuance_retry_execution_attempts
    ADD CONSTRAINT fk_fiscal_issuance_retry_execution_attempts__reference_id
    FOREIGN KEY (fiscal_issuance_reference_id)
    REFERENCES core.fiscal_issuance_references(fiscal_issuance_reference_id)
    DEFERRABLE INITIALLY IMMEDIATE;;

