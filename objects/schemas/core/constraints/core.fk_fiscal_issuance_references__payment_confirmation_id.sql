ALTER TABLE core.fiscal_issuance_references
    ADD CONSTRAINT fk_fiscal_issuance_references__payment_confirmation_id
    FOREIGN KEY (payment_confirmation_id)
    REFERENCES core.payment_confirmations(payment_confirmation_id)
    DEFERRABLE INITIALLY IMMEDIATE;;

