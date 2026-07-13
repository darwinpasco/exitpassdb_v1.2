DO $$ BEGIN
    CREATE TYPE discounts.entitlement_fingerprint_status_enum AS ENUM (
        'ACTIVE',
        'SUPERSEDED',
        'REDACTED',
        'PURGED',
        'HASH_ONLY'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;;

