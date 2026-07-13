CREATE UNIQUE INDEX IF NOT EXISTS ux_hr_identity_mappings__active_user_provider
    ON operator_console.hr_identity_mappings (user_id, hr_provider_code)
    WHERE mapping_status = 'ACTIVE';;

