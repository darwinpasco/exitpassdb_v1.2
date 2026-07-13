CREATE INDEX IF NOT EXISTS ix_operator_device_assignment_history__binding_time
    ON operator_console.operator_device_assignment_history (operator_device_binding_id, effective_from DESC);;

