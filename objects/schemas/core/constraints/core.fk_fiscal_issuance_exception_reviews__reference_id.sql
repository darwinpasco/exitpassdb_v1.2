ALTER TABLE core.fiscal_issuance_exception_reviews
    ADD CONSTRAINT fk_fiscal_issuance_exception_reviews__reference_id
    FOREIGN KEY (fiscal_issuance_reference_id)
    REFERENCES core.fiscal_issuance_references(fiscal_issuance_reference_id)
    DEFERRABLE INITIALLY IMMEDIATE;;

