CREATE INDEX IF NOT EXISTS ix_hr_identity_mappings__correlation_id
    ON operator_console.hr_identity_mappings (correlation_id)
    WHERE correlation_id IS NOT NULL;;

