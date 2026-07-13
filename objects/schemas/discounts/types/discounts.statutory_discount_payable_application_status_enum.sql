DO $$ BEGIN
    CREATE TYPE discounts.statutory_discount_payable_application_status_enum AS ENUM (
        'REQUESTED',
        'APPLIED',
        'FAILED',
        'CANCELLED'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
