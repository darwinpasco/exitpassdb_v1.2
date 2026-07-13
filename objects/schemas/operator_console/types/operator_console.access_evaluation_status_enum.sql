DO $$ BEGIN
    CREATE TYPE operator_console.access_evaluation_status_enum AS ENUM (
        'ALLOWED',
        'DENIED'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;;

