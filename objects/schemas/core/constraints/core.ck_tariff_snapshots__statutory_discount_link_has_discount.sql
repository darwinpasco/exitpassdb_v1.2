DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint con
        JOIN pg_class cls ON cls.oid = con.conrelid
        JOIN pg_namespace n ON n.oid = cls.relnamespace
        WHERE n.nspname = 'core'
          AND cls.relname = 'tariff_snapshots'
          AND con.conname = 'ck_tariff_snapshots__statutory_discount_link_has_discount'
    ) THEN
        ALTER TABLE core.tariff_snapshots
            ADD CONSTRAINT ck_tariff_snapshots__statutory_discount_link_has_discount
            CHECK (
                statutory_discount_validation_id IS NULL
                OR statutory_discount_amount > 0
            );
    END IF;
END $$;;

