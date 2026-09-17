ALTER TABLE core.parking_sessions
    ADD COLUMN IF NOT EXISTS source_adapter_identity_id uuid;

ALTER TABLE core.tariff_snapshots
    ADD COLUMN IF NOT EXISTS source_adapter_identity_id uuid;
