CREATE INDEX IF NOT EXISTS ix_tariff_snapshots__source_adapter_identity_id
    ON core.tariff_snapshots (source_adapter_identity_id);
