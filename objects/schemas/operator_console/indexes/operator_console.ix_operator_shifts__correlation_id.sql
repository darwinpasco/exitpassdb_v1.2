CREATE INDEX IF NOT EXISTS ix_operator_shifts__correlation_id
    ON operator_console.operator_shifts (correlation_id)
    WHERE correlation_id IS NOT NULL;;

