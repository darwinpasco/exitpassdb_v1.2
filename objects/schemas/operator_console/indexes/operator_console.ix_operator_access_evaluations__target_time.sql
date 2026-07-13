CREATE INDEX IF NOT EXISTS ix_operator_access_evaluations__target_time
    ON operator_console.operator_access_evaluations (target_entity_type, target_entity_id, evaluated_at DESC)
    WHERE target_entity_id IS NOT NULL;;

