CREATE INDEX IF NOT EXISTS ix_operator_shifts__mapping_status
    ON operator_console.operator_shifts (hr_identity_mapping_id, operational_status);;

