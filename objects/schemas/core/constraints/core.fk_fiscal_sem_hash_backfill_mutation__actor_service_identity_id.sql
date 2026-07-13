ALTER TABLE core.fiscal_issuance_semantic_hash_backfill_mutation_preparations
    ADD CONSTRAINT fk_fiscal_sem_hash_backfill_mutation__actor_service_identity_id
    FOREIGN KEY (actor_service_identity_id)
    REFERENCES identity.service_identities(service_identity_id)
    DEFERRABLE INITIALLY IMMEDIATE;;

