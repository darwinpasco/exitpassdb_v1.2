ALTER TABLE core.fiscal_issuance_semantic_hash_backfill_workflow_requests
    ADD CONSTRAINT fk_fiscal_sem_hash_backfill_workflow__preview_audit_id
    FOREIGN KEY (semantic_hash_recalculation_preview_audit_id)
    REFERENCES core.fiscal_issuance_semantic_hash_recalculation_previews(semantic_hash_recalculation_preview_audit_id)
    DEFERRABLE INITIALLY IMMEDIATE;;

