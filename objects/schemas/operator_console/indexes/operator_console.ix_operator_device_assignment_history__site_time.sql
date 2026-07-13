CREATE INDEX IF NOT EXISTS ix_operator_device_assignment_history__site_time
    ON operator_console.operator_device_assignment_history (site_id, effective_from DESC, effective_to);;

