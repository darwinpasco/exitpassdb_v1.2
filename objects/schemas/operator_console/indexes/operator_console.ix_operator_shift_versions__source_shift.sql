CREATE INDEX IF NOT EXISTS ix_operator_shift_versions__source_shift
    ON operator_console.operator_shift_versions (hr_provider_code, external_shift_id_hash);;

