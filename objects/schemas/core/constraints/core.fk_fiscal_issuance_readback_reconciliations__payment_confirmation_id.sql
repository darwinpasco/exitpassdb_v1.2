ALTER TABLE core.fiscal_issuance_readback_reconciliations
    ADD CONSTRAINT fk_fiscal_issuance_readback_reconciliations__payment_confirmation_id
    FOREIGN KEY (payment_confirmation_id)
    REFERENCES core.payment_confirmations(payment_confirmation_id)
    DEFERRABLE INITIALLY IMMEDIATE;;

