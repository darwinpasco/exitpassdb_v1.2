CREATE INDEX IF NOT EXISTS ix_operator_shift_versions__correlation_id
    ON operator_console.operator_shift_versions (correlation_id)
    WHERE correlation_id IS NOT NULL;;

