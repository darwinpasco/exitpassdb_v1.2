CREATE INDEX IF NOT EXISTS ix_operator_access_evaluation_reasons__source
    ON operator_console.operator_access_evaluation_reasons (reason_source, source_entity_type, source_entity_id)
    WHERE reason_source IS NOT NULL;;

