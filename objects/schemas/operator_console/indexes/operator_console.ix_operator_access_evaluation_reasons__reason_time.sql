CREATE INDEX IF NOT EXISTS ix_operator_access_evaluation_reasons__reason_time
    ON operator_console.operator_access_evaluation_reasons (reason_code, created_at DESC);;

