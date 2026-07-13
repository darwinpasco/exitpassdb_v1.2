CREATE UNIQUE INDEX IF NOT EXISTS ux_operator_device_bindings__active_mtls_thumbprint
    ON operator_console.operator_device_bindings (mtls_certificate_thumbprint)
    WHERE device_status = 'ACTIVE' AND mtls_certificate_thumbprint IS NOT NULL;;

