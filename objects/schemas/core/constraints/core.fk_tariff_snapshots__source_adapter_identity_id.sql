DO $do$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conrelid = 'core.tariff_snapshots'::regclass
          AND conname = 'fk_tariff_snapshots__source_adapter_identity_id'
    ) THEN
        ALTER TABLE core.tariff_snapshots
            ADD CONSTRAINT fk_tariff_snapshots__source_adapter_identity_id
            FOREIGN KEY (source_adapter_identity_id)
            REFERENCES identity.service_identities(service_identity_id);
    END IF;
END
$do$;
