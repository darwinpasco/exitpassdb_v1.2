CREATE INDEX IF NOT EXISTS ix_operator_access_evaluations__operator_time
    ON operator_console.operator_access_evaluations (operator_user_id, evaluated_at DESC);;

