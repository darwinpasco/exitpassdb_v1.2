CREATE UNIQUE INDEX IF NOT EXISTS ux_operator_shifts__source_shift
    ON operator_console.operator_shifts (hr_provider_code, external_shift_id_hash);;

