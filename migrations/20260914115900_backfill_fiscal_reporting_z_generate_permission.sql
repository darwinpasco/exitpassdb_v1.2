-- Backfill the canonical Z Reading generation permission for upgraded databases.
-- Role bindings remain owned by 20260914120000_fiscal_reporting_role_permission_bindings.sql.
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
  existing_permission identity.permissions%ROWTYPE;
BEGIN
  SELECT * INTO existing_permission
  FROM identity.permissions
  WHERE permission_code='fiscal-reporting.z.generate';

  IF FOUND AND existing_permission.permission_status<>'ACTIVE' THEN
    RAISE EXCEPTION
      'Cannot backfill fiscal-reporting.z.generate: existing permission lifecycle is %.',
      existing_permission.permission_status;
  END IF;

  IF FOUND AND existing_permission.permission_id<>canonical_permission_id THEN
    RAISE EXCEPTION
      'Cannot backfill fiscal-reporting.z.generate: existing permission identity is not canonical.';
  END IF;

  IF NOT FOUND AND EXISTS (
    SELECT 1 FROM identity.permissions
    WHERE permission_id=canonical_permission_id
      AND permission_code<>'fiscal-reporting.z.generate') THEN
    RAISE EXCEPTION
      'Cannot backfill fiscal-reporting.z.generate: canonical permission identity is already assigned.';
  END IF;
END $$;

INSERT INTO identity.permissions (
  permission_id,permission_code,permission_name,permission_description,
  permission_domain,permission_action,permission_status,is_sensitive,
  requires_audit,created_by_service_identity_id,updated_by_service_identity_id)
VALUES (
  pg_temp.exitpass_wave3_uuid('wave3:permission:fiscal-reporting.z.generate'),
  'fiscal-reporting.z.generate','Generate Z report','Generate a closing Z report.',
  'fiscal-reporting','generate','ACTIVE',true,true,
  '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978',
  '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978')
ON CONFLICT ON CONSTRAINT uq_permissions__permission_code DO UPDATE SET
  permission_name=EXCLUDED.permission_name,
  permission_description=EXCLUDED.permission_description,
  permission_domain=EXCLUDED.permission_domain,
  permission_action=EXCLUDED.permission_action,
  is_sensitive=EXCLUDED.is_sensitive,
  requires_audit=EXCLUDED.requires_audit,
  updated_at=now(),
  updated_by_service_identity_id=EXCLUDED.updated_by_service_identity_id,
  row_version=identity.permissions.row_version+1
WHERE identity.permissions.permission_status='ACTIVE'
  AND (identity.permissions.permission_name,
       identity.permissions.permission_description,
       identity.permissions.permission_domain,
       identity.permissions.permission_action,
       identity.permissions.is_sensitive,
       identity.permissions.requires_audit,
       identity.permissions.updated_by_service_identity_id)
    IS DISTINCT FROM
      (EXCLUDED.permission_name,
       EXCLUDED.permission_description,
       EXCLUDED.permission_domain,
       EXCLUDED.permission_action,
       EXCLUDED.is_sensitive,
       EXCLUDED.requires_audit,
       EXCLUDED.updated_by_service_identity_id);

DO $$
BEGIN
  IF (SELECT count(*) FROM identity.permissions
      WHERE permission_id=pg_temp.exitpass_wave3_uuid(
        'wave3:permission:fiscal-reporting.z.generate')
        AND permission_code='fiscal-reporting.z.generate'
        AND permission_name='Generate Z report'
        AND permission_description='Generate a closing Z report.'
        AND permission_domain='fiscal-reporting'
        AND permission_action='generate'
        AND permission_status='ACTIVE'
        AND is_sensitive
        AND requires_audit) <> 1 THEN
    RAISE EXCEPTION
      'fiscal-reporting.z.generate does not match canonical identity and metadata.';
  END IF;

  IF (SELECT count(*) FROM identity.permissions
      WHERE permission_code='fiscal-reporting.z.generate') <> 1 THEN
    RAISE EXCEPTION 'Duplicate fiscal-reporting.z.generate permissions exist.';
  END IF;
END $$;

COMMIT;
