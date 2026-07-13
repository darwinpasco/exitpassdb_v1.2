CREATE INDEX IF NOT EXISTS ix_operator_device_bindings__correlation_id
    ON operator_console.operator_device_bindings (correlation_id)
    WHERE correlation_id IS NOT NULL;;

