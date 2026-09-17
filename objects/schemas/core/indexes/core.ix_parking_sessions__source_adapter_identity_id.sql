CREATE INDEX IF NOT EXISTS ix_parking_sessions__source_adapter_identity_id
    ON core.parking_sessions (source_adapter_identity_id);
