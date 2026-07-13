ALTER TABLE core.fiscal_issuance_semantic_hash_backfill_workflow_requests
    ADD CONSTRAINT fk_fiscal_sem_hash_backfill_workflow__reference_id
    FOREIGN KEY (fiscal_issuance_reference_id)
    REFERENCES core.fiscal_issuance_references(fiscal_issuance_reference_id)
    DEFERRABLE INITIALLY IMMEDIATE;;

