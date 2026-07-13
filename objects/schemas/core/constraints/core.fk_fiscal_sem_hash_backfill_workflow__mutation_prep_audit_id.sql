ALTER TABLE core.fiscal_issuance_semantic_hash_backfill_workflow_requests
    ADD CONSTRAINT fk_fiscal_sem_hash_backfill_workflow__mutation_prep_audit_id
    FOREIGN KEY (mutation_preparation_audit_id)
    REFERENCES core.fiscal_issuance_semantic_hash_backfill_mutation_preparations(semantic_hash_backfill_mutation_audit_id)
    DEFERRABLE INITIALLY IMMEDIATE;;

