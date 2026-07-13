DO $$ BEGIN
    CREATE TYPE operator_console.shift_revocation_status_enum AS ENUM (
        'REQUESTED',
        'APPROVED',
        'REJECTED',
        'CANCELLED',
        'EFFECTIVE',
        'EXPIRED'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;;

