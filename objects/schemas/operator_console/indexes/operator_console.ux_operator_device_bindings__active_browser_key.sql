CREATE UNIQUE INDEX IF NOT EXISTS ux_operator_device_bindings__active_browser_key
    ON operator_console.operator_device_bindings (browser_key_thumbprint)
    WHERE device_status = 'ACTIVE' AND browser_key_thumbprint IS NOT NULL;;

