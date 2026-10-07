-- ExitPass v1.3 governed Site + Vehicle Type continuity tariff configuration.
-- Additive and rerunnable. Transaction quotes remain in core.tariff_snapshots.

CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TABLE IF NOT EXISTS sites.vehicle_types (
    vehicle_type_code varchar(32) PRIMARY KEY,
    display_name varchar(80) NOT NULL,
    vehicle_type_status varchar(16) NOT NULL DEFAULT 'ACTIVE',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    row_version bigint NOT NULL DEFAULT 1,
    CONSTRAINT ck_vehicle_types__code CHECK (
        vehicle_type_code = upper(vehicle_type_code)
        AND vehicle_type_code ~ '^[A-Z][A-Z0-9_]{1,31}$'),
    CONSTRAINT ck_vehicle_types__status CHECK (vehicle_type_status IN ('ACTIVE', 'RETIRED')),
    CONSTRAINT ck_vehicle_types__row_version CHECK (row_version > 0)
);

INSERT INTO sites.vehicle_types (vehicle_type_code, display_name)
VALUES
    ('CAR', 'Car'),
    ('MOTORCYCLE', 'Motorcycle'),
    ('SUV_MPV', 'SUV / MPV'),
    ('VAN', 'Van'),
    ('BUS', 'Bus'),
    ('TRUCK', 'Truck'),
    ('LIGHT_TRUCK', 'Light Truck'),
    ('TRICYCLE', 'Tricycle'),
    ('OTHER', 'Other'),
    ('UNKNOWN', 'Unknown')
ON CONFLICT (vehicle_type_code) DO UPDATE
SET display_name = EXCLUDED.display_name,
    updated_at = CASE WHEN sites.vehicle_types.display_name IS DISTINCT FROM EXCLUDED.display_name
        THEN now() ELSE sites.vehicle_types.updated_at END,
    row_version = CASE WHEN sites.vehicle_types.display_name IS DISTINCT FROM EXCLUDED.display_name
        THEN sites.vehicle_types.row_version + 1 ELSE sites.vehicle_types.row_version END;

ALTER TABLE sessions.vendor_session_projections
    ADD COLUMN IF NOT EXISTS vendor_vehicle_type_code varchar(64),
    ADD COLUMN IF NOT EXISTS canonical_vehicle_type_code varchar(32);

ALTER TABLE core.parking_sessions
    ADD COLUMN IF NOT EXISTS canonical_vehicle_type_code varchar(32);

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_vendor_session_projections__vehicle_type') THEN
        ALTER TABLE sessions.vendor_session_projections
            ADD CONSTRAINT fk_vendor_session_projections__vehicle_type
            FOREIGN KEY (canonical_vehicle_type_code) REFERENCES sites.vehicle_types(vehicle_type_code);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_parking_sessions__vehicle_type') THEN
        ALTER TABLE core.parking_sessions
            ADD CONSTRAINT fk_parking_sessions__vehicle_type
            FOREIGN KEY (canonical_vehicle_type_code) REFERENCES sites.vehicle_types(vehicle_type_code);
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS ix_vendor_session_projections__vehicle_type
    ON sessions.vendor_session_projections (site_id, canonical_vehicle_type_code)
    WHERE canonical_vehicle_type_code IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_parking_sessions__vehicle_type
    ON core.parking_sessions (site_id, canonical_vehicle_type_code)
    WHERE canonical_vehicle_type_code IS NOT NULL;

CREATE TABLE IF NOT EXISTS sites.site_tariff_definitions (
    site_tariff_definition_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id uuid NOT NULL REFERENCES sites.sites(site_id),
    vehicle_type_code varchar(32) NOT NULL REFERENCES sites.vehicle_types(vehicle_type_code),
    tariff_code varchar(64) NOT NULL,
    tariff_name varchar(160) NOT NULL,
    version varchar(80) NOT NULL,
    currency_code char(3) NOT NULL,
    parking_grace_period_minutes integer NOT NULL,
    post_payment_exit_grace_minutes integer,
    daily_max_fee_minor_units bigint,
    quote_validity_minutes integer NOT NULL,
    effective_from timestamptz NOT NULL,
    effective_to timestamptz,
    status varchar(16) NOT NULL,
    verified_at timestamptz,
    verified_by_user_id uuid REFERENCES identity.users(user_id),
    activated_at timestamptz,
    activated_by_user_id uuid REFERENCES identity.users(user_id),
    retired_at timestamptz,
    retired_by_user_id uuid REFERENCES identity.users(user_id),
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by_user_id uuid REFERENCES identity.users(user_id),
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by_user_id uuid REFERENCES identity.users(user_id),
    row_version bigint NOT NULL DEFAULT 1,
    CONSTRAINT uq_site_tariff_definitions__code_version UNIQUE (tariff_code, version),
    CONSTRAINT ck_site_tariff_definitions__code CHECK (
        tariff_code = upper(tariff_code) AND tariff_code ~ '^[A-Z0-9][A-Z0-9_-]{2,63}$'),
    CONSTRAINT ck_site_tariff_definitions__version CHECK (
        version ~ '^[A-Za-z0-9][A-Za-z0-9._-]{0,79}$'),
    CONSTRAINT ck_site_tariff_definitions__currency CHECK (currency_code = upper(currency_code)),
    CONSTRAINT ck_site_tariff_definitions__grace CHECK (parking_grace_period_minutes BETWEEN 0 AND 1440),
    CONSTRAINT ck_site_tariff_definitions__post_payment_grace CHECK (
        post_payment_exit_grace_minutes IS NULL OR post_payment_exit_grace_minutes BETWEEN 0 AND 1440),
    CONSTRAINT ck_site_tariff_definitions__daily_max CHECK (
        daily_max_fee_minor_units IS NULL OR daily_max_fee_minor_units >= 0),
    CONSTRAINT ck_site_tariff_definitions__quote_validity CHECK (quote_validity_minutes BETWEEN 1 AND 1440),
    CONSTRAINT ck_site_tariff_definitions__effectivity CHECK (
        effective_to IS NULL OR effective_to > effective_from),
    CONSTRAINT ck_site_tariff_definitions__status CHECK (status IN ('DRAFT', 'ACTIVE', 'RETIRED')),
    CONSTRAINT ck_site_tariff_definitions__activation CHECK (
        status <> 'ACTIVE' OR (verified_at IS NOT NULL AND activated_at IS NOT NULL)),
    CONSTRAINT ck_site_tariff_definitions__retirement CHECK (
        status <> 'RETIRED' OR retired_at IS NOT NULL),
    CONSTRAINT ck_site_tariff_definitions__row_version CHECK (row_version > 0)
);

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ex_site_tariff_definitions__active_effectivity') THEN
        ALTER TABLE sites.site_tariff_definitions
            ADD CONSTRAINT ex_site_tariff_definitions__active_effectivity
            EXCLUDE USING gist (
                site_id WITH =,
                vehicle_type_code WITH =,
                tstzrange(effective_from, COALESCE(effective_to, 'infinity'::timestamptz), '[)') WITH &&)
            WHERE (status = 'ACTIVE');
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS ix_site_tariff_definitions__runtime
    ON sites.site_tariff_definitions (site_id, vehicle_type_code, status, effective_from, effective_to);

CREATE TABLE IF NOT EXISTS sites.site_tariff_rules (
    site_tariff_rule_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    site_tariff_definition_id uuid NOT NULL
        REFERENCES sites.site_tariff_definitions(site_tariff_definition_id) ON DELETE RESTRICT,
    sequence integer NOT NULL,
    rule_scope varchar(24) NOT NULL,
    charge_type varchar(24) NOT NULL,
    duration_start_minutes integer,
    duration_end_minutes integer,
    clock_start_time time,
    clock_end_time time,
    amount_minor_units bigint NOT NULL,
    billing_unit_minutes integer,
    rounding_rule varchar(32),
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by_user_id uuid REFERENCES identity.users(user_id),
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by_user_id uuid REFERENCES identity.users(user_id),
    row_version bigint NOT NULL DEFAULT 1,
    CONSTRAINT uq_site_tariff_rules__sequence UNIQUE (site_tariff_definition_id, sequence),
    CONSTRAINT ck_site_tariff_rules__sequence CHECK (sequence > 0),
    CONSTRAINT ck_site_tariff_rules__scope CHECK (rule_scope IN ('DURATION', 'CLOCK_TIME')),
    CONSTRAINT ck_site_tariff_rules__charge_type CHECK (charge_type IN ('UNIT_DURATION', 'FLAT_RATE', 'SESSION')),
    CONSTRAINT ck_site_tariff_rules__duration_shape CHECK (
        (rule_scope = 'DURATION'
         AND duration_start_minutes IS NOT NULL AND duration_start_minutes >= 0
         AND (duration_end_minutes IS NULL OR duration_end_minutes > duration_start_minutes)
         AND clock_start_time IS NULL AND clock_end_time IS NULL)
        OR
        (rule_scope = 'CLOCK_TIME'
         AND duration_start_minutes IS NULL AND duration_end_minutes IS NULL
         AND clock_start_time IS NOT NULL AND clock_end_time IS NOT NULL
         AND clock_start_time <> clock_end_time)),
    CONSTRAINT ck_site_tariff_rules__amount CHECK (amount_minor_units >= 0),
    CONSTRAINT ck_site_tariff_rules__unit_shape CHECK (
        (charge_type = 'UNIT_DURATION'
         AND billing_unit_minutes IS NOT NULL AND billing_unit_minutes > 0
         AND rounding_rule = 'WHOLE_STARTED_HOUR')
        OR
        (charge_type IN ('FLAT_RATE', 'SESSION')
         AND billing_unit_minutes IS NULL AND rounding_rule IS NULL)),
    CONSTRAINT ck_site_tariff_rules__row_version CHECK (row_version > 0)
);

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ex_site_tariff_rules__duration_ranges') THEN
        ALTER TABLE sites.site_tariff_rules
            ADD CONSTRAINT ex_site_tariff_rules__duration_ranges
            EXCLUDE USING gist (
                site_tariff_definition_id WITH =,
                int4range(duration_start_minutes, duration_end_minutes, '[)') WITH &&)
            WHERE (rule_scope = 'DURATION');
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS ix_site_tariff_rules__definition_sequence
    ON sites.site_tariff_rules (site_tariff_definition_id, sequence);

-- Configuration permissions are separate from dashboard/reporting access.
INSERT INTO identity.permissions (
    permission_code, permission_name, permission_description, permission_domain,
    permission_action, permission_status, is_sensitive, requires_audit)
VALUES
    ('jurisdiction.view', 'View jurisdictions', 'View governed LGU and jurisdiction configuration.', 'platform-config', 'view', 'ACTIVE', false, true),
    ('jurisdiction.manage', 'Manage jurisdictions', 'Create and update governed LGU and jurisdiction configuration.', 'platform-config', 'manage', 'ACTIVE', true, true),
    ('site-tariff.view', 'View Site tariffs', 'View governed Site and Vehicle Type tariff configuration.', 'platform-config', 'view', 'ACTIVE', false, true),
    ('site-tariff.manage', 'Manage Site tariffs', 'Draft, verify, activate, version, and retire Site tariffs.', 'platform-config', 'manage', 'ACTIVE', true, true)
ON CONFLICT (permission_code) DO UPDATE
SET permission_name = EXCLUDED.permission_name,
    permission_description = EXCLUDED.permission_description,
    permission_domain = EXCLUDED.permission_domain,
    permission_action = EXCLUDED.permission_action,
    permission_status = 'ACTIVE',
    is_sensitive = EXCLUDED.is_sensitive,
    requires_audit = EXCLUDED.requires_audit,
    updated_at = now(),
    row_version = identity.permissions.row_version + 1;

INSERT INTO identity.role_permissions (
    role_id, permission_id, binding_status, binding_reason_code,
    effective_from, assigned_by_service_identity_id,
    created_by_service_identity_id, updated_by_service_identity_id)
SELECT role.role_id, permission.permission_id, 'ACTIVE', 'V13_GOVERNED_SITE_TARIFF_CONFIGURATION',
       '2026-10-06T00:00:00+08:00'::timestamptz,
       '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'::uuid,
       '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'::uuid,
       '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'::uuid
FROM identity.roles role
JOIN identity.permissions permission ON permission.permission_code IN (
    'jurisdiction.view', 'jurisdiction.manage', 'site-tariff.view', 'site-tariff.manage')
WHERE role.role_code = 'SYSTEM_ADMINISTRATOR'
  AND NOT EXISTS (
      SELECT 1 FROM identity.role_permissions existing
      WHERE existing.role_id = role.role_id
        AND existing.permission_id = permission.permission_id
        AND existing.binding_status = 'ACTIVE');

INSERT INTO identity.role_permissions (
    role_id, permission_id, binding_status, binding_reason_code,
    effective_from, assigned_by_service_identity_id,
    created_by_service_identity_id, updated_by_service_identity_id)
SELECT role.role_id, permission.permission_id, 'ACTIVE', 'V13_GOVERNED_JURISDICTION_POLICY_CONFIGURATION',
       '2026-10-06T00:00:00+08:00'::timestamptz,
       '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'::uuid,
       '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'::uuid,
       '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'::uuid
FROM identity.roles role
JOIN identity.permissions permission ON permission.permission_code = 'jurisdiction.view'
WHERE role.role_code = 'COMPLIANCE_POLICY_ADMINISTRATOR'
  AND NOT EXISTS (
      SELECT 1 FROM identity.role_permissions existing
      WHERE existing.role_id = role.role_id
        AND existing.permission_id = permission.permission_id
        AND existing.binding_status = 'ACTIVE');

-- PITX Level 3 is the approved operational continuity Site for this slice.
UPDATE sites.sites
SET site_status = 'ACTIVE',
    public_lookup_enabled = true,
    payment_enabled = true,
    updated_at = now(),
    row_version = row_version + 1
WHERE site_id = '2d1dcdf8-f563-537c-8542-0bde7cc9da97'::uuid
  AND site_code = 'PITX-LEVEL-3'
  AND (site_status <> 'ACTIVE' OR NOT public_lookup_enabled OR NOT payment_enabled);

-- Approved PITX Level 3 CAR continuity tariff. No other Site/vehicle tariff is inferred.
INSERT INTO sites.site_tariff_definitions (
    site_tariff_definition_id, site_id, vehicle_type_code, tariff_code, tariff_name,
    version, currency_code, parking_grace_period_minutes,
    post_payment_exit_grace_minutes, daily_max_fee_minor_units, quote_validity_minutes,
    effective_from, status, verified_at, activated_at)
SELECT
    'b6ec5a68-828d-5f0a-8f5c-f79926279736'::uuid,
    site.site_id, 'CAR', 'PITX-L3-CAR', 'PITX Level 3 Car Continuity Tariff',
    'PITX-L3-CAR-V1', 'PHP', 15, NULL, NULL, 5,
    '2026-10-06T00:00:00+08:00'::timestamptz, 'ACTIVE',
    '2026-10-06T00:00:00+08:00'::timestamptz,
    '2026-10-06T00:00:00+08:00'::timestamptz
FROM sites.sites site
WHERE site.site_id = '2d1dcdf8-f563-537c-8542-0bde7cc9da97'::uuid
  AND site.site_code = 'PITX-LEVEL-3'
ON CONFLICT (tariff_code, version) DO NOTHING;

INSERT INTO sites.site_tariff_rules (
    site_tariff_rule_id, site_tariff_definition_id, sequence, rule_scope,
    charge_type, duration_start_minutes, duration_end_minutes,
    amount_minor_units, billing_unit_minutes, rounding_rule)
SELECT
    '0d698f82-2bb4-5d09-9f79-f56e907d8cac'::uuid,
    definition.site_tariff_definition_id, 1, 'DURATION', 'UNIT_DURATION',
    0, NULL, 5000, 60, 'WHOLE_STARTED_HOUR'
FROM sites.site_tariff_definitions definition
WHERE definition.tariff_code = 'PITX-L3-CAR'
  AND definition.version = 'PITX-L3-CAR-V1'
ON CONFLICT (site_tariff_definition_id, sequence) DO NOTHING;

COMMENT ON TABLE sites.site_tariff_definitions IS
    'Governed, versioned tariff masters for ExitPass continuity calculation by Site and vehicle type.';
COMMENT ON TABLE sites.site_tariff_rules IS
    'Ordered duration or clock-time rules belonging to one immutable activated Site tariff version.';
COMMENT ON COLUMN sessions.vendor_session_projections.canonical_vehicle_type_code IS
    'Safely normalized ExitPass vehicle type. NULL means continuity payment must fail closed.';
COMMENT ON COLUMN core.parking_sessions.canonical_vehicle_type_code IS
    'Canonical vehicle type retained when a vendor or projected session is materialized.';
