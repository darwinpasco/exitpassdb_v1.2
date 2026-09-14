-- Complete the canonical SYSTEM_ADMIN permission set after the fiscal-reporting upgrade.
-- No other role-permission binding is created or changed by this migration.
\set ON_ERROR_STOP on

BEGIN;

CREATE OR REPLACE FUNCTION pg_temp.exitpass_wave3_uuid(input text)
RETURNS uuid LANGUAGE sql IMMUTABLE AS $fn$
  SELECT (substr(md5(input),1,8)||'-'||substr(md5(input),9,4)||'-'||
          substr(md5(input),13,4)||'-'||substr(md5(input),17,4)||'-'||
          substr(md5(input),21,12))::uuid
$fn$;

DO $$
DECLARE
  canonical_permission_id constant uuid :=
    pg_temp.exitpass_wave3_uuid('wave3:permission:fiscal-reporting.z.generate');
  canonical_binding_id constant uuid :=
    pg_temp.exitpass_wave3_uuid(
      'wave3:role-permission:SYSTEM_ADMIN:fiscal-reporting.z.generate');
  system_admin_role_id uuid;
  existing_binding identity.role_permissions%ROWTYPE;
BEGIN
  SELECT role_id INTO system_admin_role_id
  FROM identity.roles
  WHERE role_code='SYSTEM_ADMIN'
    AND role_provenance='CANONICAL_ROLE'
    AND role_status='ACTIVE';

  IF system_admin_role_id IS NULL OR
     (SELECT count(*) FROM identity.roles
      WHERE role_code='SYSTEM_ADMIN'
        AND role_provenance='CANONICAL_ROLE'
        AND role_status='ACTIVE') <> 1 THEN
    RAISE EXCEPTION
      'SYSTEM_ADMIN does not match the active canonical role identity.';
  END IF;

  IF (SELECT count(*) FROM identity.permissions
      WHERE permission_id=canonical_permission_id
        AND permission_code='fiscal-reporting.z.generate'
        AND permission_status='ACTIVE') <> 1 THEN
    RAISE EXCEPTION
      'fiscal-reporting.z.generate does not match the active canonical permission identity.';
  END IF;

  SELECT * INTO existing_binding
  FROM identity.role_permissions
  WHERE role_id=system_admin_role_id
    AND permission_id=canonical_permission_id;

  IF FOUND AND existing_binding.binding_status<>'ACTIVE' THEN
    RAISE EXCEPTION
      'Cannot establish SYSTEM_ADMIN fiscal-reporting.z.generate: existing binding lifecycle is %.',
      existing_binding.binding_status;
  END IF;

  IF FOUND AND existing_binding.role_permission_id<>canonical_binding_id THEN
    RAISE EXCEPTION
      'Cannot establish SYSTEM_ADMIN fiscal-reporting.z.generate: existing binding identity is not canonical.';
  END IF;

  IF NOT FOUND AND EXISTS (
    SELECT 1 FROM identity.role_permissions
    WHERE role_permission_id=canonical_binding_id
      AND (role_id<>system_admin_role_id OR permission_id<>canonical_permission_id)) THEN
    RAISE EXCEPTION
      'Cannot establish SYSTEM_ADMIN fiscal-reporting.z.generate: canonical binding identity is already assigned.';
  END IF;
END $$;

INSERT INTO identity.role_permissions (
  role_permission_id,role_id,permission_id,binding_status,binding_reason_code,
  assigned_by_service_identity_id,effective_from,created_by_service_identity_id,
  updated_by_service_identity_id)
SELECT
  pg_temp.exitpass_wave3_uuid(
    'wave3:role-permission:SYSTEM_ADMIN:fiscal-reporting.z.generate'),
  role.role_id,permission.permission_id,'ACTIVE',
  'WAVE3_CANONICAL_PERMISSION_REVIEW',
  '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978','2020-01-01T00:00:00Z',
  '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978',
  '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
FROM identity.roles role
JOIN identity.permissions permission
  ON permission.permission_code='fiscal-reporting.z.generate'
WHERE role.role_code='SYSTEM_ADMIN'
  AND NOT EXISTS (
    SELECT 1 FROM identity.role_permissions existing
    WHERE existing.role_id=role.role_id
      AND existing.permission_id=permission.permission_id)
ON CONFLICT (role_permission_id) DO NOTHING;

DO $$
BEGIN
  IF (SELECT count(*) FROM identity.role_permissions binding
      JOIN identity.roles role ON role.role_id=binding.role_id
      JOIN identity.permissions permission
        ON permission.permission_id=binding.permission_id
      WHERE binding.role_permission_id=pg_temp.exitpass_wave3_uuid(
        'wave3:role-permission:SYSTEM_ADMIN:fiscal-reporting.z.generate')
        AND role.role_code='SYSTEM_ADMIN'
        AND permission.permission_code='fiscal-reporting.z.generate'
        AND binding.binding_status='ACTIVE'
        AND binding.binding_reason_code='WAVE3_CANONICAL_PERMISSION_REVIEW'
        AND binding.assigned_by_service_identity_id=
          '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
        AND binding.effective_from='2020-01-01T00:00:00Z'
        AND binding.created_by_service_identity_id=
          '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
        AND binding.updated_by_service_identity_id=
          '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978') <> 1 THEN
    RAISE EXCEPTION
      'SYSTEM_ADMIN fiscal-reporting.z.generate binding is not canonical.';
  END IF;

  IF EXISTS (
    SELECT role_id,permission_id FROM identity.role_permissions
    WHERE binding_status='ACTIVE'
    GROUP BY role_id,permission_id HAVING count(*)>1) THEN
    RAISE EXCEPTION 'Duplicate ACTIVE role-permission bindings exist.';
  END IF;
END $$;

COMMIT;
