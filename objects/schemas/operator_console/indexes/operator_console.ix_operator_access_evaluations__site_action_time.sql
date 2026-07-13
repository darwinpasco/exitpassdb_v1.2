CREATE INDEX IF NOT EXISTS ix_operator_access_evaluations__site_action_time
    ON operator_console.operator_access_evaluations (site_id, requested_action, evaluated_at DESC);;

