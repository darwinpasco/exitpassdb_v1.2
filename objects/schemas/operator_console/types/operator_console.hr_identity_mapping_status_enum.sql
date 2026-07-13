DO $$ BEGIN
    CREATE TYPE operator_console.hr_identity_mapping_status_enum AS ENUM (
        'ACTIVE',
        'SUSPENDED',
        'REVOKED',
        'EXPIRED',
        'SUPERSEDED'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;;

