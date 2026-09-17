-- Approved v1.3 APT human operational RBAC validation.
-- All fixture mutations are transactional and rolled back.

BEGIN;

UPDATE sites.site_groups SET site_group_status='ACTIVE'
WHERE site_group_id='a6dbadf6-68b5-5bed-a7e0-a75faee70841';
UPDATE sites.sites SET site_status='ACTIVE'
WHERE site_id='2d1dcdf8-f563-537c-8542-0bde7cc9da97';

DO $$
DECLARE
  legacy_codes constant text[] := ARRAY[
    'apt.access','cashier-shifts.operate','cash-custody.operate','terminal-cash.receive'];
BEGIN
  IF (SELECT count(*) FROM identity.permissions
      WHERE permission_code=ANY(legacy_codes) AND permission_status='ACTIVE')<>4 THEN
    RAISE EXCEPTION 'The granular APT permission catalog is incomplete.';
  END IF;
  IF (SELECT count(*) FROM identity.permissions
      WHERE permission_code='apt.cashier.operate' AND permission_status='ACTIVE')<>1 THEN
    RAISE EXCEPTION 'The approved apt.cashier.operate permission is unavailable.';
  END IF;
  IF EXISTS (
    SELECT 1 FROM identity.role_permissions rp
    JOIN identity.roles r ON r.role_id=rp.role_id
    JOIN identity.permissions p ON p.permission_id=rp.permission_id
    WHERE rp.binding_status='ACTIVE' AND p.permission_code=ANY(legacy_codes)
      AND r.role_code IN ('SITE_OPERATOR','OPERATIONS_SUPERVISOR','APT_CASHIER_OPERATOR')) THEN
    RAISE EXCEPTION 'A legacy granular APT binding remains on an approved operational role.';
  END IF;
  IF (SELECT count(*) FROM identity.role_permissions rp
      JOIN identity.roles r ON r.role_id=rp.role_id
      JOIN identity.permissions p ON p.permission_id=rp.permission_id
      WHERE rp.binding_status='ACTIVE' AND r.role_code='APT_CASHIER_OPERATOR'
        AND p.permission_code='apt.cashier.operate')<>1 THEN
    RAISE EXCEPTION 'APT_CASHIER_OPERATOR does not have exactly one apt.cashier.operate binding.';
  END IF;
  IF EXISTS (
    SELECT 1 FROM identity.user_role_scope_grants sg
    JOIN identity.user_roles ur ON ur.user_role_id=sg.user_role_id
    JOIN identity.roles r ON r.role_id=ur.role_id
    WHERE r.role_code='APT_CASHIER_OPERATOR'
      AND sg.grant_status IN ('PENDING','ACTIVE','SUSPENDED')
      AND sg.scope_type<>'SITE') THEN
    RAISE EXCEPTION 'APT_CASHIER_OPERATOR has a current non-Site scope.';
  END IF;
END $$;

INSERT INTO identity.users (
  user_id,username,display_name,user_type,user_status,effective_from,
  created_by_service_identity_id,updated_by_service_identity_id)
VALUES (
  '21021b00-0000-4000-8000-000000000001','i021b.validation.cashier',
  'I-021B Validation Cashier','OPERATIONS_USER','ACTIVE',now()-interval '1 minute',
  '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978','1f2ffdfb-c4a9-5a00-a656-9f3a132b1978');

INSERT INTO identity.user_roles (
  user_role_id,user_id,role_id,assignment_status,assignment_reason_code,
  assigned_by_service_identity_id,effective_from,
  created_by_service_identity_id,updated_by_service_identity_id)
SELECT
  '21021b00-0000-4000-8000-000000000002',
  '21021b00-0000-4000-8000-000000000001',role_id,
  'ACTIVE','I021B_VALIDATION','1f2ffdfb-c4a9-5a00-a656-9f3a132b1978',now()-interval '1 minute',
  '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978','1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
FROM identity.roles WHERE role_code='APT_CASHIER_OPERATOR';

INSERT INTO identity.user_role_scope_grants (
  user_role_scope_grant_id,user_role_id,scope_type,site_id,grant_status,
  grant_reason_code,effective_from,granted_by_service_identity_id,
  created_by_service_identity_id,updated_by_service_identity_id)
SELECT
  '21021b00-0000-4000-8000-000000000003',
  '21021b00-0000-4000-8000-000000000002','SITE',site_id,'ACTIVE',
  'I021B_VALIDATION',now()-interval '1 minute',
  '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978',
  '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978','1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
FROM sites.sites WHERE site_status='ACTIVE' ORDER BY site_id LIMIT 1;

DO $$
DECLARE effective_count integer;
BEGIN
  SELECT count(DISTINCT permission.permission_code) INTO effective_count
  FROM identity.users human_user
  JOIN identity.user_roles user_role ON user_role.user_id=human_user.user_id
  JOIN identity.roles role ON role.role_id=user_role.role_id
  JOIN identity.role_permissions role_permission ON role_permission.role_id=role.role_id
  JOIN identity.permissions permission ON permission.permission_id=role_permission.permission_id
  JOIN identity.user_role_scope_grants scope_grant ON scope_grant.user_role_id=user_role.user_role_id
  WHERE human_user.user_id='21021b00-0000-4000-8000-000000000001'
    AND human_user.user_status='ACTIVE' AND user_role.assignment_status='ACTIVE'
    AND role.role_status='ACTIVE' AND role_permission.binding_status='ACTIVE'
    AND permission.permission_status='ACTIVE' AND permission.permission_code='apt.cashier.operate'
    AND scope_grant.grant_status='ACTIVE' AND scope_grant.scope_type='SITE';
  IF effective_count<>1 THEN
    RAISE EXCEPTION 'Effective APT cashier authorization count was %, expected one.', effective_count;
  END IF;
END $$;

ROLLBACK;
SELECT 'Approved v1.3 APT operational RBAC validation passed.' AS validation_result;
