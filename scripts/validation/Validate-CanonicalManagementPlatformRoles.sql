\set ON_ERROR_STOP on

DO $$
DECLARE canonical_count integer;
BEGIN
  SELECT count(*) INTO canonical_count FROM identity.roles
  WHERE role_provenance='CANONICAL_ROLE' AND human_assignable;
  IF canonical_count <> 14 THEN
    RAISE EXCEPTION 'Expected 14 canonical human roles, found %.', canonical_count;
  END IF;

  IF EXISTS (SELECT 1 FROM identity.roles WHERE role_code='SITE_ADMINISTRATOR') THEN
    RAISE EXCEPTION 'SITE_ADMINISTRATOR must not exist.';
  END IF;
  IF EXISTS (SELECT 1 FROM identity.roles WHERE role_code='SERVICE_PRINCIPAL'
             AND (role_provenance<>'SERVICE_ROLE' OR human_assignable OR direct_add_user_eligible)) THEN
    RAISE EXCEPTION 'SERVICE_PRINCIPAL is not correctly service-only.';
  END IF;
  IF EXISTS (SELECT 1 FROM identity.roles WHERE role_code IN ('FINANCE_RECONCILIATION','OPERATOR_SUPPORT_STAFF')
             AND (role_provenance<>'HISTORICAL_LEGACY_ROLE' OR role_status<>'RETIRED' OR human_assignable)) THEN
    RAISE EXCEPTION 'Historical roles are not correctly retired.';
  END IF;
  IF EXISTS (
    SELECT 1 FROM identity.role_permissions rp
    JOIN identity.roles r ON r.role_id=rp.role_id
    JOIN identity.permissions p ON p.permission_id=rp.permission_id
    WHERE r.role_provenance='CANONICAL_ROLE' AND rp.binding_status='ACTIVE'
      AND p.permission_code='uat-fixture.manage') THEN
    RAISE EXCEPTION 'A canonical role has uat-fixture.manage.';
  END IF;
  IF EXISTS (
    SELECT 1 FROM identity.role_permissions rp JOIN identity.roles r ON r.role_id=rp.role_id
    JOIN identity.permissions p ON p.permission_id=rp.permission_id
    WHERE r.role_code='FINANCE_RECONCILIATION_ANALYST' AND rp.binding_status='ACTIVE'
      AND p.permission_code IN ('payments.finalize','fiscal-reporting.z.generate')) THEN
    RAISE EXCEPTION 'Finance analyst has payment finalization or Z generation.';
  END IF;
  IF EXISTS (
    SELECT 1 FROM identity.role_permissions rp JOIN identity.roles r ON r.role_id=rp.role_id
    JOIN identity.permissions p ON p.permission_id=rp.permission_id
    WHERE r.role_code='SUPPORT_AGENT' AND rp.binding_status='ACTIVE'
      AND p.permission_code IN ('payments.create_attempt','payments.finalize','coupons.apply','discounts.validate_statutory','statutory-discounts.decision.approve')) THEN
    RAISE EXCEPTION 'Support Agent has prohibited payment/discount mutation.';
  END IF;
  IF EXISTS (
    SELECT 1 FROM identity.role_permissions rp JOIN identity.roles r ON r.role_id=rp.role_id
    JOIN identity.permissions p ON p.permission_id=rp.permission_id
    WHERE r.role_code='SECURITY_REVIEWER' AND rp.binding_status='ACTIVE' AND p.permission_code='identity.manage') THEN
    RAISE EXCEPTION 'Security Reviewer still has identity.manage.';
  END IF;
  IF (SELECT count(*) FROM identity.role_user_type_compatibility c
      JOIN identity.roles r ON r.role_id=c.role_id WHERE r.role_provenance='CANONICAL_ROLE') <> 14 THEN
    RAISE EXCEPTION 'Canonical compatibility matrix is incomplete.';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM identity.role_user_type_compatibility c JOIN identity.roles r ON r.role_id=c.role_id
                 WHERE r.role_code='EXECUTIVE_MANAGEMENT' AND c.user_type='OTHER') THEN
    RAISE EXCEPTION 'Executive Management must use existing OTHER user type.';
  END IF;
END $$;

SELECT role_code,role_name,role_provenance,role_status,is_privileged,
       requires_elevated_approval,direct_add_user_eligible,human_assignable
FROM identity.roles
WHERE role_provenance IN ('CANONICAL_ROLE','HISTORICAL_LEGACY_ROLE','SERVICE_ROLE')
ORDER BY role_provenance,role_code;
