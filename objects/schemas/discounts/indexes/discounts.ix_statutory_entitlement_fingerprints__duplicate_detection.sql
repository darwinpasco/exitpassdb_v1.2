CREATE INDEX IF NOT EXISTS ix_statutory_entitlement_fingerprints__duplicate_detection
    ON discounts.statutory_entitlement_fingerprints (
        entitlement_type,
        duplicate_detection_scope,
        fingerprint_hash
    )
    WHERE fingerprint_status = 'ACTIVE';;

