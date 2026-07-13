CREATE INDEX IF NOT EXISTS ix_operator_shift_versions__shift_imported_at
    ON operator_console.operator_shift_versions (operator_shift_id, imported_at DESC);;

