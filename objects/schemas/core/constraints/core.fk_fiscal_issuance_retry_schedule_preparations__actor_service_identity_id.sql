ALTER TABLE core.fiscal_issuance_retry_schedule_preparations
    ADD CONSTRAINT fk_fiscal_issuance_retry_schedule_preparations__actor_service_identity_id
    FOREIGN KEY (actor_service_identity_id)
    REFERENCES identity.service_identities(service_identity_id)
    DEFERRABLE INITIALLY IMMEDIATE;;

