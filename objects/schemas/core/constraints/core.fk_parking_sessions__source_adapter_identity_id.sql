DO $do$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conrelid = 'core.parking_sessions'::regclass
          AND conname = 'fk_parking_sessions__source_adapter_identity_id'
    ) THEN
        ALTER TABLE core.parking_sessions
            ADD CONSTRAINT fk_parking_sessions__source_adapter_identity_id
            FOREIGN KEY (source_adapter_identity_id)
            REFERENCES identity.service_identities(service_identity_id);
    END IF;
END
$do$;
