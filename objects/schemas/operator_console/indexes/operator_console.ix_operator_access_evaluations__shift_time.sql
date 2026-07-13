CREATE INDEX IF NOT EXISTS ix_operator_access_evaluations__shift_time
    ON operator_console.operator_access_evaluations (operator_shift_id, evaluated_at DESC);;

