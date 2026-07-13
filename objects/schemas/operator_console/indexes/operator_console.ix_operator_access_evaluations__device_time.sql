CREATE INDEX IF NOT EXISTS ix_operator_access_evaluations__device_time
    ON operator_console.operator_access_evaluations (operator_device_binding_id, evaluated_at DESC);;

