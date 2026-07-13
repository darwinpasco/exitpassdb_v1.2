ALTER TABLE core.fiscal_issuance_semantic_hash_recalculation_previews
    ADD CONSTRAINT fk_fiscal_issuance_semantic_hash_recalculation_previews__actor_service_identity_id
    FOREIGN KEY (actor_service_identity_id)
    REFERENCES identity.service_identities(service_identity_id)
    DEFERRABLE INITIALLY IMMEDIATE;;

