CREATE INDEX IF NOT EXISTS ix_hr_identity_mappings__user_status
    ON operator_console.hr_identity_mappings (user_id, mapping_status);;

