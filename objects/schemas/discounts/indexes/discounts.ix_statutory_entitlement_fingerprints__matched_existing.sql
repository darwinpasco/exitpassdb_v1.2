CREATE INDEX IF NOT EXISTS ix_statutory_entitlement_fingerprints__matched_existing
    ON discounts.statutory_entitlement_fingerprints (matched_existing_fingerprint_id)
    WHERE matched_existing_fingerprint_id IS NOT NULL;;

