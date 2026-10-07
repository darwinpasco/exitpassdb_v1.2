DO $$
DECLARE
    definition_count integer;
    rule_count integer;
    implicit_count integer;
BEGIN
    IF (SELECT count(*) FROM sites.vehicle_types) <> 10 THEN
        RAISE EXCEPTION 'Canonical vehicle type catalog is incomplete.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'sessions' AND table_name = 'vendor_session_projections'
          AND column_name = 'canonical_vehicle_type_code')
       OR NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'core' AND table_name = 'parking_sessions'
          AND column_name = 'canonical_vehicle_type_code') THEN
        RAISE EXCEPTION 'Canonical vehicle provenance columns are missing.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM sites.sites
        WHERE site_id = '2d1dcdf8-f563-537c-8542-0bde7cc9da97'::uuid
          AND site_code = 'PITX-LEVEL-3'
          AND site_status = 'ACTIVE'
          AND public_lookup_enabled
          AND payment_enabled) THEN
        RAISE EXCEPTION 'PITX Level 3 is not in the approved operational Site posture.';
    END IF;

    SELECT count(*) INTO definition_count
    FROM sites.site_tariff_definitions
    WHERE site_id = '2d1dcdf8-f563-537c-8542-0bde7cc9da97'::uuid
      AND vehicle_type_code = 'CAR'
      AND tariff_code = 'PITX-L3-CAR'
      AND version = 'PITX-L3-CAR-V1'
      AND currency_code = 'PHP'
      AND parking_grace_period_minutes = 15
      AND daily_max_fee_minor_units IS NULL
      AND post_payment_exit_grace_minutes IS NULL
      AND status = 'ACTIVE';
    IF definition_count <> 1 THEN
        RAISE EXCEPTION 'Expected exactly one approved PITX Level 3 CAR tariff, found %.', definition_count;
    END IF;

    SELECT count(*) INTO rule_count
    FROM sites.site_tariff_rules rule
    JOIN sites.site_tariff_definitions definition
      ON definition.site_tariff_definition_id = rule.site_tariff_definition_id
    WHERE definition.tariff_code = 'PITX-L3-CAR'
      AND definition.version = 'PITX-L3-CAR-V1'
      AND rule.sequence = 1
      AND rule.rule_scope = 'DURATION'
      AND rule.charge_type = 'UNIT_DURATION'
      AND rule.duration_start_minutes = 0
      AND rule.duration_end_minutes IS NULL
      AND rule.amount_minor_units = 5000
      AND rule.billing_unit_minutes = 60
      AND rule.rounding_rule = 'WHOLE_STARTED_HOUR';
    IF rule_count <> 1 THEN
        RAISE EXCEPTION 'The approved PITX CAR tariff rule is missing or malformed.';
    END IF;

    SELECT count(*) INTO implicit_count
    FROM sites.site_tariff_definitions
    WHERE site_id = '2d1dcdf8-f563-537c-8542-0bde7cc9da97'::uuid
      AND vehicle_type_code <> 'CAR'
      AND status = 'ACTIVE';
    IF implicit_count <> 0 THEN
        RAISE EXCEPTION 'PITX has % unauthorized implicit non-CAR tariff(s).', implicit_count;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM identity.roles role
        JOIN identity.role_permissions binding ON binding.role_id = role.role_id AND binding.binding_status = 'ACTIVE'
        JOIN identity.permissions permission ON permission.permission_id = binding.permission_id
        WHERE role.role_code = 'SYSTEM_ADMINISTRATOR'
        GROUP BY role.role_id
        HAVING count(*) FILTER (WHERE permission.permission_code IN (
            'jurisdiction.view', 'jurisdiction.manage', 'site-tariff.view', 'site-tariff.manage')) = 4) THEN
        RAISE EXCEPTION 'System Administrator configuration permissions are incomplete.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM identity.roles role
        JOIN identity.role_permissions binding ON binding.role_id = role.role_id AND binding.binding_status = 'ACTIVE'
        JOIN identity.permissions permission ON permission.permission_id = binding.permission_id
        WHERE role.role_code NOT IN ('SYSTEM_ADMINISTRATOR')
          AND permission.permission_code IN ('jurisdiction.manage', 'site-tariff.manage')) THEN
        RAISE EXCEPTION 'Sensitive configuration management permissions were broadened unexpectedly.';
    END IF;

    RAISE NOTICE 'EXITPASS_SITE_VEHICLE_TARIFF_CONFIGURATION_VALID';
END $$;
