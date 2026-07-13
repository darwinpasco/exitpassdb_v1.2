CREATE INDEX IF NOT EXISTS ix_statutory_entitlement_fingerprints__correlation_id
    ON discounts.statutory_entitlement_fingerprints (correlation_id)
    WHERE correlation_id IS NOT NULL;;

