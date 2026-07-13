ALTER TABLE core.fiscal_issuance_readback_reconciliations
    ADD CONSTRAINT fk_fiscal_issuance_readback_reconciliations__actor_service_identity_id
    FOREIGN KEY (actor_service_identity_id)
    REFERENCES identity.service_identities(service_identity_id)
    DEFERRABLE INITIALLY IMMEDIATE;;

