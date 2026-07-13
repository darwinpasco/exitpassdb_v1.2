ALTER TABLE core.fiscal_issuance_semantic_hash_recalculation_previews
    ADD CONSTRAINT fk_fiscal_issuance_semantic_hash_recalculation_previews__reference_id
    FOREIGN KEY (fiscal_issuance_reference_id)
    REFERENCES core.fiscal_issuance_references(fiscal_issuance_reference_id)
    DEFERRABLE INITIALLY IMMEDIATE;;

