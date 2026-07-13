ALTER TABLE core.fiscal_issuance_references
    ADD COLUMN IF NOT EXISTS semantic_request_hash_value varchar(64);;

