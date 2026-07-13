CREATE INDEX IF NOT EXISTS ix_operator_access_evaluation_reasons__evaluation_order
    ON operator_console.operator_access_evaluation_reasons (operator_access_evaluation_id, display_order);;

