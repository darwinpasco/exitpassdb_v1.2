CREATE UNIQUE INDEX IF NOT EXISTS ux_operator_device_bindings__device_binding_code
    ON operator_console.operator_device_bindings (device_binding_code);;

