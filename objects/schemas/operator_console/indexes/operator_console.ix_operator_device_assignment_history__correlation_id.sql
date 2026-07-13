CREATE INDEX IF NOT EXISTS ix_operator_device_assignment_history__correlation_id
    ON operator_console.operator_device_assignment_history (correlation_id)
    WHERE correlation_id IS NOT NULL;;

