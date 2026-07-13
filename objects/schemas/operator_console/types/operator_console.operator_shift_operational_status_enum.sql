DO $$ BEGIN
    CREATE TYPE operator_console.operator_shift_operational_status_enum AS ENUM (
        'SCHEDULED',
        'ACTIVE',
        'ENDED',
        'SUSPENDED',
        'REVOKED',
        'TAKEN_OVER',
        'CANCELLED',
        'IMPORT_CONFLICT'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;;

