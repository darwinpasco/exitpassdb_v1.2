-- Add the approved operational fiscal-reporting bindings to the canonical Wave 3 roles.
-- This migration creates no roles or permissions and preserves all historical binding rows.
\set ON_ERROR_STOP on

BEGIN;

CREATE OR REPLACE FUNCTION pg_temp.exitpass_fiscal_reporting_rbac_uuid(input text)
RETURNS uuid LANGUAGE sql IMMUTABLE AS $fn$
  SELECT (substr(md5(input),1,8)||'-'||substr(md5(input),9,4)||'-'||
          substr(md5(input),13,4)||'-'||substr(md5(input),17,4)||'-'||
          substr(md5(input),21,12))::uuid
$fn$;

CREATE TEMP TABLE fiscal_reporting_role_bindings (
  role_code varchar(64) NOT NULL,
  permission_code varchar(96) NOT NULL,
  PRIMARY KEY (role_code, permission_code)
) ON COMMIT DROP;

INSERT INTO fiscal_reporting_role_bindings VALUES
('SITE_OPERATOR','fiscal-reporting.ej.read'),
('SITE_OPERATOR','fiscal-reporting.ej.export'),
('SITE_OPERATOR','fiscal-reporting.x.read'),
('SITE_OPERATOR','fiscal-reporting.x.generate'),
('SITE_OPERATOR','fiscal-reporting.z.read'),
('OPERATIONS_SUPERVISOR','fiscal-reporting.ej.read'),
('OPERATIONS_SUPERVISOR','fiscal-reporting.ej.export'),
('OPERATIONS_SUPERVISOR','fiscal-reporting.x.read'),
('OPERATIONS_SUPERVISOR','fiscal-reporting.x.generate'),
('OPERATIONS_SUPERVISOR','fiscal-reporting.z.read'),
('OPERATIONS_SUPERVISOR','fiscal-reporting.z.generate');

DO $$
BEGIN
  IF (SELECT count(*) FROM identity.roles r
      WHERE r.role_code IN ('SITE_OPERATOR','OPERATIONS_SUPERVISOR')
        AND r.role_provenance='CANONICAL_ROLE'
        AND r.role_status='ACTIVE'
        AND r.human_assignable) <> 2 THEN
    RAISE EXCEPTION 'Fiscal-reporting RBAC correction requires active, human-assignable canonical operational roles.';
  END IF;

  IF (SELECT count(*) FROM identity.permissions p
      WHERE p.permission_code IN (
        'fiscal-reporting.ej.read','fiscal-reporting.ej.export',
        'fiscal-reporting.x.read','fiscal-reporting.x.generate',
        'fiscal-reporting.z.read','fiscal-reporting.z.generate')
        AND p.permission_status='ACTIVE') <> 6 THEN
    RAISE EXCEPTION 'Fiscal-reporting RBAC correction requires the six canonical ACTIVE permissions.';
  END IF;

  IF EXISTS (
    SELECT 1 FROM identity.role_permissions rp
    JOIN identity.roles r ON r.role_id=rp.role_id
    JOIN identity.permissions p ON p.permission_id=rp.permission_id
    WHERE r.role_code='SITE_OPERATOR'
      AND p.permission_code='fiscal-reporting.z.generate'
      AND rp.binding_status='ACTIVE') THEN
    RAISE EXCEPTION 'SITE_OPERATOR already has prohibited fiscal-reporting.z.generate authority.';
  END IF;
END $$;

INSERT INTO identity.role_permissions (
  role_permission_id,role_id,permission_id,binding_status,binding_reason_code,
  assigned_by_service_identity_id,effective_from,created_by_service_identity_id,
  updated_by_service_identity_id)
SELECT
  CASE
    WHEN EXISTS (
      SELECT 1
      FROM identity.role_permissions historical
      WHERE historical.role_permission_id=pg_temp.exitpass_fiscal_reporting_rbac_uuid(
        'wave3:role-permission:'||binding.role_code||':'||binding.permission_code))
    THEN pg_temp.exitpass_fiscal_reporting_rbac_uuid(
      'migration:20260914120000:fiscal-reporting-role-permission:'||binding.role_code||':'||binding.permission_code)
    ELSE pg_temp.exitpass_fiscal_reporting_rbac_uuid(
      'wave3:role-permission:'||binding.role_code||':'||binding.permission_code)
  END,
  role.role_id,
  permission.permission_id,
  'ACTIVE',
  'FISCAL_REPORTING_OPERATIONAL_ROLE_CORRECTION',
  '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978',
  '2020-01-01T00:00:00Z',
  '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978',
  '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
FROM fiscal_reporting_role_bindings binding
JOIN identity.roles role ON role.role_code=binding.role_code
JOIN identity.permissions permission ON permission.permission_code=binding.permission_code
WHERE NOT EXISTS (
  SELECT 1 FROM identity.role_permissions active
  WHERE active.role_id=role.role_id
    AND active.permission_id=permission.permission_id
    AND active.binding_status='ACTIVE')
ON CONFLICT (role_permission_id) DO NOTHING;

DO $$
BEGIN
  IF (SELECT count(*) FROM fiscal_reporting_role_bindings binding
      JOIN identity.roles role ON role.role_code=binding.role_code
      JOIN identity.permissions permission ON permission.permission_code=binding.permission_code
      JOIN identity.role_permissions rp
        ON rp.role_id=role.role_id
       AND rp.permission_id=permission.permission_id
       AND rp.binding_status='ACTIVE') <> 11 THEN
    RAISE EXCEPTION 'Fiscal-reporting RBAC correction did not establish all eleven approved bindings.';
  END IF;

  IF EXISTS (
    SELECT role_id,permission_id FROM identity.role_permissions
    WHERE binding_status='ACTIVE'
    GROUP BY role_id,permission_id HAVING count(*)>1) THEN
    RAISE EXCEPTION 'Fiscal-reporting RBAC correction found duplicate ACTIVE role-permission bindings.';
  END IF;
END $$;

COMMIT;
