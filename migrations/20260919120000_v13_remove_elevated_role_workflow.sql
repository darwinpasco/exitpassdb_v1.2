-- Remove elevated approval from the eight approved human roles and complete System Administrator security administration.
BEGIN;

DO $$
DECLARE
    approved_codes constant text[] := ARRAY[
        'SYSTEM_ADMINISTRATOR','OPERATIONS_SUPERVISOR','SITE_OPERATOR','PARKING_ATTENDANT',
        'APT_CASHIER_OPERATOR','FINANCE_RECONCILIATION_ANALYST',
        'COMPLIANCE_POLICY_ADMINISTRATOR','EXECUTIVE_MANAGEMENT'];
BEGIN
    IF (SELECT count(*) FROM identity.roles
        WHERE role_code = ANY(approved_codes)
          AND role_provenance = 'CANONICAL_ROLE' AND role_status = 'ACTIVE') <> 8 THEN
        RAISE EXCEPTION 'The eight approved active canonical roles must exist before elevated workflow removal.';
    END IF;

    UPDATE identity.roles
    SET requires_elevated_approval = false,
        human_assignable = true,
        direct_add_user_eligible = true,
        updated_at = now(),
        row_version = row_version + 1
    WHERE role_code = ANY(approved_codes)
      AND role_provenance = 'CANONICAL_ROLE'
      AND role_status = 'ACTIVE'
      AND (requires_elevated_approval, human_assignable, direct_add_user_eligible)
          IS DISTINCT FROM (false, true, true);
END $$;

INSERT INTO identity.role_permissions (
    role_permission_id, role_id, permission_id, binding_status, binding_reason_code,
    assigned_by_service_identity_id, effective_from,
    created_by_service_identity_id, updated_by_service_identity_id)
SELECT gen_random_uuid(), r.role_id, p.permission_id, 'ACTIVE',
       'V13_SYSTEM_ADMIN_SECURITY_ADMINISTRATION',
       '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978', now(),
       '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978',
       '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
FROM identity.roles r
CROSS JOIN identity.permissions p
WHERE r.role_code = 'SYSTEM_ADMINISTRATOR'
  AND p.permission_code IN (
      'human-authentication.credential.reset',
      'human-authentication.mfa.status.view',
      'human-authentication.mfa.reset',
      'human-authentication.mfa.remove')
  AND NOT EXISTS (
      SELECT 1 FROM identity.role_permissions active
      WHERE active.role_id = r.role_id AND active.permission_id = p.permission_id
        AND active.binding_status = 'ACTIVE');

COMMIT;
