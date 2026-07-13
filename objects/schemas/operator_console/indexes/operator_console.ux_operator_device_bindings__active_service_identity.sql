CREATE UNIQUE INDEX IF NOT EXISTS ux_operator_device_bindings__active_service_identity
    ON operator_console.operator_device_bindings (service_identity_id)
    WHERE device_status = 'ACTIVE' AND service_identity_id IS NOT NULL;;

