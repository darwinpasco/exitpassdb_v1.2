CREATE INDEX IF NOT EXISTS ix_operator_device_bindings__site_status
    ON operator_console.operator_device_bindings (site_id, device_status, trust_level);;

