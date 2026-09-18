-- Make all eight approved human roles directly assignable by Add User on existing databases.
-- Permission bindings, privilege metadata, descriptions, and scope policy are unchanged.
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
        RAISE EXCEPTION 'The eight approved active canonical roles must exist before direct Add User enablement.';
    END IF;

    UPDATE identity.roles
    SET human_assignable = true,
        direct_add_user_eligible = true,
        updated_at = now(),
        row_version = row_version + 1
    WHERE role_code = ANY(approved_codes)
      AND role_provenance = 'CANONICAL_ROLE'
      AND role_status = 'ACTIVE'
      AND (human_assignable, direct_add_user_eligible) IS DISTINCT FROM (true, true);
END $$;

COMMIT;
