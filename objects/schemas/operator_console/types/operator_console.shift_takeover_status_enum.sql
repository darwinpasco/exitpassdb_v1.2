DO $$ BEGIN
    CREATE TYPE operator_console.shift_takeover_status_enum AS ENUM (
        'REQUESTED',
        'PENDING_APPROVAL',
        'APPROVED',
        'REJECTED',
        'ACTIVE',
        'ENDED',
        'CANCELLED',
        'EXPIRED'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;;

