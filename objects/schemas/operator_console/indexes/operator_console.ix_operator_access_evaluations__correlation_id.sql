CREATE INDEX IF NOT EXISTS ix_operator_access_evaluations__correlation_id
    ON operator_console.operator_access_evaluations (correlation_id)
    WHERE correlation_id IS NOT NULL;;

