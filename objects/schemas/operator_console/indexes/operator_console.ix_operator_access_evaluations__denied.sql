CREATE INDEX IF NOT EXISTS ix_operator_access_evaluations__denied
    ON operator_console.operator_access_evaluations (evaluated_at DESC, requested_action)
    WHERE evaluation_status = 'DENIED';;

