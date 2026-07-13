CREATE INDEX IF NOT EXISTS ix_operator_device_bindings__last_seen
    ON operator_console.operator_device_bindings (last_seen_at DESC);;

