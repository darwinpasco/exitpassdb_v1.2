CREATE UNIQUE INDEX IF NOT EXISTS ux_hr_identity_mappings__active_external_person
    ON operator_console.hr_identity_mappings (hr_provider_code, external_person_id_hash)
    WHERE mapping_status = 'ACTIVE';;

