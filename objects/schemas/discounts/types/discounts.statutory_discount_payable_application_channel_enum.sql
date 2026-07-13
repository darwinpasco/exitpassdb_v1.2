DO $$ BEGIN
    CREATE TYPE discounts.statutory_discount_payable_application_channel_enum AS ENUM (
        'OPERATOR_CONSOLE',
        'OPERATOR_ASSISTED',
        'SYSTEM'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;;

