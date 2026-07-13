DO $$ BEGIN
    CREATE TYPE operator_console.operator_device_trust_level_enum AS ENUM (
        'BROWSER_KEY_ONLY',
        'MTLS_ONLY',
        'BROWSER_KEY_AND_MTLS',
        'UNVERIFIED'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;;

