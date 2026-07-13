ALTER TABLE core.fiscal_issuance_references
    ADD CONSTRAINT fk_fiscal_issuance_references__payment_attempt_id
    FOREIGN KEY (payment_attempt_id)
    REFERENCES core.payment_attempts(payment_attempt_id)
    DEFERRABLE INITIALLY IMMEDIATE;;

