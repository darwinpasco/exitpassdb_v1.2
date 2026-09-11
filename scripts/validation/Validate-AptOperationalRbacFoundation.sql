-- I-021B canonical APT operational RBAC validation.
-- All fixture mutations are transactional and rolled back.

BEGIN;

-- The canonical clean-build catalog intentionally begins in DRAFT. Activate one
-- real PITX Site only inside this rolled-back validator; do not depend on the
-- former MNT development topology to supply an ACTIVE business Site.
UPDATE sites.site_groups
SET site_group_status = 'ACTIVE'
WHERE site_group_id = 'a6dbadf6-68b5-5bed-a7e0-a75faee70841';

UPDATE sites.sites
SET site_status = 'ACTIVE'
WHERE site_id = '2d1dcdf8-f563-537c-8542-0bde7cc9da97';

DO $$
DECLARE
    required_codes constant text[] := ARRAY[
        'apt.access',
        'cashier-shifts.operate',
        'cash-custody.operate',
        'terminal-cash.receive'
    ];
    expected_permission_ids constant uuid[] := ARRAY[
        '6bcab461-3595-145e-5807-c8449228cdb6'::uuid,
        '307d7772-6b84-d76f-0e7e-980fab9a1e5c'::uuid,
        'cd0e161b-3010-f559-1486-fbcd65dc9434'::uuid,
        '93989b4d-6be8-27c8-8053-1cc128cbcc20'::uuid
    ];
    expected_binding_ids constant uuid[] := ARRAY[
        'fd1580da-c069-5250-e49f-697d767af8a1'::uuid,
        '45b48318-f583-7fd1-d048-d1e753f4057a'::uuid,
        '06730455-c02f-4f7f-d89a-c822f76ab2f0'::uuid,
        'e1504522-9e04-571d-d507-9b9441012ee4'::uuid
    ];
    site_operator_id constant uuid := 'd187851f-88fd-5974-b595-07367ad1a3b4'::uuid;
BEGIN
    IF (SELECT count(*) FROM identity.permissions WHERE permission_code = ANY(required_codes) AND permission_status = 'ACTIVE') <> 4 THEN
        RAISE EXCEPTION 'Required ACTIVE APT operational permission catalog is incomplete or duplicated.';
    END IF;

    IF (SELECT array_agg(permission_id ORDER BY permission_id) FROM identity.permissions WHERE permission_code = ANY(required_codes))
       IS DISTINCT FROM (SELECT array_agg(value ORDER BY value) FROM unnest(expected_permission_ids) value) THEN
        RAISE EXCEPTION 'APT operational permission identifiers differ from the canonical IDs.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM identity.permissions
        WHERE permission_code = ANY(required_codes)
          AND (requires_audit IS NOT TRUE
               OR permission_domain <> split_part(permission_code, '.', 1)
               OR permission_action NOT IN ('access', 'operate', 'receive'))
    ) THEN
        RAISE EXCEPTION 'APT operational permission metadata is not canonical.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM identity.roles
        WHERE role_id = site_operator_id AND role_code = 'SITE_OPERATOR' AND role_status = 'ACTIVE'
    ) THEN
        RAISE EXCEPTION 'Canonical SITE_OPERATOR role is missing or inactive.';
    END IF;

    IF (SELECT count(*)
        FROM identity.role_permissions rp
        JOIN identity.permissions p ON p.permission_id = rp.permission_id
        WHERE rp.role_id = site_operator_id
          AND p.permission_code = ANY(required_codes)
          AND rp.binding_status = 'ACTIVE') <> 4 THEN
        RAISE EXCEPTION 'SITE_OPERATOR does not have exactly four ACTIVE APT operational bindings.';
    END IF;

    IF (SELECT array_agg(rp.role_permission_id ORDER BY rp.role_permission_id)
        FROM identity.role_permissions rp
        JOIN identity.permissions p ON p.permission_id = rp.permission_id
        WHERE rp.role_id = site_operator_id
          AND p.permission_code = ANY(required_codes)
          AND rp.binding_status = 'ACTIVE')
       IS DISTINCT FROM (SELECT array_agg(value ORDER BY value) FROM unnest(expected_binding_ids) value) THEN
        RAISE EXCEPTION 'SITE_OPERATOR APT binding identifiers differ from the canonical IDs.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM identity.roles r
        JOIN identity.role_permissions rp ON rp.role_id = r.role_id AND rp.binding_status = 'ACTIVE'
        JOIN identity.permissions p ON p.permission_id = rp.permission_id
        WHERE r.role_code = 'OPERATIONS_SUPERVISOR'
          AND p.permission_code = ANY(required_codes)
    ) THEN
        RAISE EXCEPTION 'OPERATIONS_SUPERVISOR has automatic APT cashier authority.';
    END IF;

    IF EXISTS (SELECT 1 FROM identity.permissions WHERE permission_code ILIKE '%handover%') THEN
        RAISE EXCEPTION 'A supervisor handover permission was introduced before DR-08/DR-09 approval.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM identity.user_role_scope_grants scope_grant
        JOIN identity.user_roles user_role ON user_role.user_role_id = scope_grant.user_role_id
        JOIN identity.role_permissions role_permission ON role_permission.role_id = user_role.role_id AND role_permission.binding_status = 'ACTIVE'
        JOIN identity.permissions permission ON permission.permission_id = role_permission.permission_id
        WHERE scope_grant.scope_type = 'GLOBAL'
          AND scope_grant.grant_status = 'ACTIVE'
          AND permission.permission_code = ANY(required_codes)
    ) THEN
        RAISE EXCEPTION 'An explicit GLOBAL grant supplies APT operational authority.';
    END IF;

    IF (SELECT count(*)
        FROM identity.role_permissions rp
        JOIN identity.permissions p ON p.permission_id = rp.permission_id
        WHERE rp.role_id = site_operator_id
          AND rp.binding_status = 'ACTIVE'
          AND p.permission_code IN ('sessions.resolve', 'gate.consume_authorization', 'gate.record_event', 'operations.manual_gate')) <> 4 THEN
        RAISE EXCEPTION 'Existing SITE_OPERATOR baseline permissions were not preserved.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM identity.permissions operational
        JOIN identity.permissions payable_basis
          ON payable_basis.permission_code = 'terminal-cash.payable-basis.read'
        WHERE operational.permission_code = ANY(required_codes)
          AND operational.permission_id = payable_basis.permission_id
    ) THEN
        RAISE EXCEPTION 'APT operational permissions are conflated with payable-basis read authority.';
    END IF;
END $$;

INSERT INTO identity.users (
    user_id, username, display_name, user_type, user_status, effective_from,
    created_by_service_identity_id, updated_by_service_identity_id
) VALUES (
    '21021b00-0000-4000-8000-000000000001', 'i021b.validation.cashier', 'I-021B Validation Cashier',
    'SITE_OPERATOR', 'ACTIVE', now() - interval '1 minute',
    '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978', '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
);

INSERT INTO identity.user_roles (
    user_role_id, user_id, role_id, assignment_status, assignment_reason_code,
    assigned_by_service_identity_id, effective_from,
    created_by_service_identity_id, updated_by_service_identity_id
) VALUES (
    '21021b00-0000-4000-8000-000000000002',
    '21021b00-0000-4000-8000-000000000001',
    'd187851f-88fd-5974-b595-07367ad1a3b4',
    'ACTIVE', 'I021B_VALIDATION', '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978', now() - interval '1 minute',
    '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978', '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
);

INSERT INTO identity.user_role_scope_grants (
    user_role_scope_grant_id, user_role_id, scope_type, site_id, grant_status,
    grant_reason_code, effective_from, granted_by_service_identity_id,
    created_by_service_identity_id, updated_by_service_identity_id
)
SELECT
    '21021b00-0000-4000-8000-000000000003',
    '21021b00-0000-4000-8000-000000000002',
    'SITE', site_id, 'ACTIVE', 'I021B_VALIDATION', now() - interval '1 minute',
    '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978',
    '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978',
    '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
FROM sites.sites
WHERE site_status = 'ACTIVE'
ORDER BY site_id
LIMIT 1;

DO $$
DECLARE
    effective_count integer;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM identity.user_role_scope_grants WHERE user_role_scope_grant_id = '21021b00-0000-4000-8000-000000000003') THEN
        RAISE EXCEPTION 'No ACTIVE canonical Site was available for the scope fixture.';
    END IF;

    SELECT count(DISTINCT permission.permission_code)
    INTO effective_count
    FROM identity.users human_user
    JOIN identity.user_roles user_role ON user_role.user_id = human_user.user_id
    JOIN identity.roles role ON role.role_id = user_role.role_id
    JOIN identity.role_permissions role_permission ON role_permission.role_id = role.role_id
    JOIN identity.permissions permission ON permission.permission_id = role_permission.permission_id
    JOIN identity.user_role_scope_grants scope_grant ON scope_grant.user_role_id = user_role.user_role_id
    WHERE human_user.user_id = '21021b00-0000-4000-8000-000000000001'
      AND human_user.user_status = 'ACTIVE'
      AND human_user.effective_from <= now()
      AND (human_user.effective_to IS NULL OR human_user.effective_to > now())
      AND user_role.assignment_status = 'ACTIVE'
      AND user_role.effective_from <= now()
      AND (user_role.effective_to IS NULL OR user_role.effective_to > now())
      AND role.role_status = 'ACTIVE'
      AND role_permission.binding_status = 'ACTIVE'
      AND role_permission.effective_from <= now()
      AND (role_permission.effective_to IS NULL OR role_permission.effective_to > now())
      AND permission.permission_status = 'ACTIVE'
      AND permission.permission_code = ANY(ARRAY['apt.access', 'cashier-shifts.operate', 'cash-custody.operate', 'terminal-cash.receive'])
      AND scope_grant.grant_status = 'ACTIVE'
      AND scope_grant.scope_type = 'SITE'
      AND scope_grant.effective_from <= now()
      AND (scope_grant.effective_to IS NULL OR scope_grant.effective_to > now());

    IF effective_count <> 4 THEN
        RAISE EXCEPTION 'Effective authorization join returned % required APT permissions instead of four.', effective_count;
    END IF;
END $$;

UPDATE identity.role_permissions rp
SET binding_status = 'REVOKED',
    effective_to = now(),
    revoked_at = now(),
    revoked_by_service_identity_id = '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978',
    revocation_reason_code = 'I021B_VALIDATION',
    updated_at = now(),
    updated_by_service_identity_id = '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978',
    row_version = rp.row_version + 1
FROM identity.permissions p
WHERE rp.permission_id = p.permission_id
  AND rp.role_id = 'd187851f-88fd-5974-b595-07367ad1a3b4'
  AND p.permission_code = 'apt.access'
  AND rp.binding_status = 'ACTIVE';

DO $$
DECLARE
    effective_count integer;
BEGIN
    SELECT count(DISTINCT permission.permission_code)
    INTO effective_count
    FROM identity.users human_user
    JOIN identity.user_roles user_role ON user_role.user_id = human_user.user_id AND user_role.assignment_status = 'ACTIVE'
    JOIN identity.role_permissions role_permission ON role_permission.role_id = user_role.role_id AND role_permission.binding_status = 'ACTIVE'
    JOIN identity.permissions permission ON permission.permission_id = role_permission.permission_id AND permission.permission_status = 'ACTIVE'
    JOIN identity.user_role_scope_grants scope_grant ON scope_grant.user_role_id = user_role.user_role_id AND scope_grant.grant_status = 'ACTIVE'
    WHERE human_user.user_id = '21021b00-0000-4000-8000-000000000001'
      AND permission.permission_code = ANY(ARRAY['apt.access', 'cashier-shifts.operate', 'cash-custody.operate', 'terminal-cash.receive']);

    IF effective_count <> 3 THEN
        RAISE EXCEPTION 'Revoking one role-permission binding did not remove exactly one effective permission; count was %.', effective_count;
    END IF;
END $$;

ROLLBACK;

SELECT 'I-021B APT operational RBAC foundation validation passed.' AS validation_result;
