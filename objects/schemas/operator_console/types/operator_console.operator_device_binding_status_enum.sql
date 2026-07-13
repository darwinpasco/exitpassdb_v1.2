DO $$ BEGIN
    CREATE TYPE operator_console.operator_device_binding_status_enum AS ENUM (
        'PENDING',
        'ACTIVE',
        'SUSPENDED',
        'REVOKED',
        'LOST',
        'EXPIRED',
        'RETIRED'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;;

