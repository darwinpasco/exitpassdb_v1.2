\set ON_ERROR_STOP on

DO $$
DECLARE
  canonical_count integer;
  fiscal_codes constant text[] := ARRAY[
    'fiscal-reporting.ej.read','fiscal-reporting.ej.export',
    'fiscal-reporting.x.read','fiscal-reporting.x.generate',
    'fiscal-reporting.z.read','fiscal-reporting.z.generate'];
  site_operator_fiscal_codes constant text[] := ARRAY[
    'fiscal-reporting.ej.read','fiscal-reporting.ej.export',
    'fiscal-reporting.x.read','fiscal-reporting.x.generate',
    'fiscal-reporting.z.read'];
  site_operator_existing_codes constant text[] := ARRAY[
    'sessions.resolve','gate.consume_authorization','gate.record_event','operations.manual_gate',
    'apt.access','cashier-shifts.operate','cash-custody.operate','terminal-cash.receive'];
  operations_supervisor_existing_codes constant text[] := ARRAY[
    'statutory-discounts.review.queue.read','statutory-discounts.review.detail.read',
    'statutory-discounts.evidence.review.view','statutory-discounts.decision.review',
    'statutory-discounts.decision.approve','statutory-discounts.decision.reject',
    'statutory-discounts.policy.resolve','fiscal-issuance.status.read',
    'operator-workflow-audit.view','projection-health.view',
    'ops.vendor-session-projection-health.view','vendor-acknowledgments.view'];
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

  IF (SELECT count(*) FROM identity.permissions
      WHERE permission_status='ACTIVE' AND permission_code=ANY(fiscal_codes)) <> 6 THEN
    RAISE EXCEPTION 'The six canonical fiscal-reporting permissions are missing, duplicated, or inactive.';
  END IF;

  IF (SELECT count(*) FROM identity.role_permissions rp
      JOIN identity.roles r ON r.role_id=rp.role_id
      JOIN identity.permissions p ON p.permission_id=rp.permission_id
      WHERE r.role_code='SITE_OPERATOR' AND rp.binding_status='ACTIVE'
        AND p.permission_code=ANY(site_operator_fiscal_codes)) <> 5
     OR EXISTS (
      SELECT 1 FROM identity.role_permissions rp
      JOIN identity.roles r ON r.role_id=rp.role_id
      JOIN identity.permissions p ON p.permission_id=rp.permission_id
      WHERE r.role_code='SITE_OPERATOR' AND rp.binding_status='ACTIVE'
        AND p.permission_code=ANY(fiscal_codes)
        AND NOT (p.permission_code=ANY(site_operator_fiscal_codes))) THEN
    RAISE EXCEPTION 'SITE_OPERATOR fiscal-reporting authority is not the approved five-permission non-closing set.';
  END IF;

  IF (SELECT count(*) FROM identity.role_permissions rp
      JOIN identity.roles r ON r.role_id=rp.role_id
      JOIN identity.permissions p ON p.permission_id=rp.permission_id
      WHERE r.role_code='OPERATIONS_SUPERVISOR' AND rp.binding_status='ACTIVE'
        AND p.permission_code=ANY(fiscal_codes)) <> 6 THEN
    RAISE EXCEPTION 'OPERATIONS_SUPERVISOR does not have all six fiscal-reporting permissions.';
  END IF;

  IF (SELECT count(*) FROM identity.role_permissions rp
      JOIN identity.roles r ON r.role_id=rp.role_id
      JOIN identity.permissions p ON p.permission_id=rp.permission_id
      WHERE r.role_code='SITE_OPERATOR' AND rp.binding_status='ACTIVE'
        AND p.permission_code=ANY(site_operator_existing_codes)) <> 8 THEN
    RAISE EXCEPTION 'Existing SITE_OPERATOR operational and APT/cash permissions were not preserved.';
  END IF;

  IF (SELECT count(*) FROM identity.role_permissions rp
      JOIN identity.roles r ON r.role_id=rp.role_id
      JOIN identity.permissions p ON p.permission_id=rp.permission_id
      WHERE r.role_code='OPERATIONS_SUPERVISOR' AND rp.binding_status='ACTIVE'
        AND p.permission_code=ANY(operations_supervisor_existing_codes)) <> 12 THEN
    RAISE EXCEPTION 'Existing OPERATIONS_SUPERVISOR permissions were not preserved.';
  END IF;

  IF EXISTS (
    SELECT 1 FROM identity.role_permissions rp
    JOIN identity.roles r ON r.role_id=rp.role_id
    JOIN identity.permissions p ON p.permission_id=rp.permission_id
    WHERE r.role_code='OPERATIONS_SUPERVISOR' AND rp.binding_status='ACTIVE'
      AND p.permission_code IN ('apt.access','cashier-shifts.operate','cash-custody.operate','terminal-cash.receive')) THEN
    RAISE EXCEPTION 'OPERATIONS_SUPERVISOR received automatic APT cashier authority.';
  END IF;

  IF EXISTS (
    SELECT 1 FROM identity.roles r
    WHERE r.role_code IN ('SITE_OPERATOR','OPERATIONS_SUPERVISOR')
      AND (r.role_provenance<>'CANONICAL_ROLE' OR r.role_status<>'ACTIVE'
        OR r.role_type<>'OPERATIONS' OR NOT r.human_assignable
        OR (r.role_code='SITE_OPERATOR' AND (r.is_privileged OR r.requires_elevated_approval OR NOT r.direct_add_user_eligible))
        OR (r.role_code='OPERATIONS_SUPERVISOR' AND (NOT r.is_privileged OR NOT r.requires_elevated_approval OR r.direct_add_user_eligible)))) THEN
    RAISE EXCEPTION 'Operational role provenance, status, assignability, or privilege metadata changed.';
  END IF;

  IF (SELECT count(*) FROM identity.role_permissions rp
      JOIN identity.roles r ON r.role_id=rp.role_id
      JOIN identity.permissions p ON p.permission_id=rp.permission_id
      WHERE r.role_code='SYSTEM_ADMIN' AND rp.binding_status='ACTIVE'
        AND p.permission_code=ANY(fiscal_codes)) <> 6
     OR (SELECT count(*) FROM identity.role_permissions rp
      JOIN identity.roles r ON r.role_id=rp.role_id
      JOIN identity.permissions p ON p.permission_id=rp.permission_id
      WHERE r.role_code='FINANCE_RECONCILIATION_ANALYST' AND rp.binding_status='ACTIVE'
        AND p.permission_code=ANY(fiscal_codes)) <> 5
     OR EXISTS (
      SELECT 1 FROM identity.role_permissions rp
      JOIN identity.roles r ON r.role_id=rp.role_id
      JOIN identity.permissions p ON p.permission_id=rp.permission_id
      WHERE r.role_provenance='CANONICAL_ROLE' AND rp.binding_status='ACTIVE'
        AND p.permission_code=ANY(fiscal_codes)
        AND r.role_code NOT IN ('SYSTEM_ADMIN','SITE_OPERATOR','OPERATIONS_SUPERVISOR','FINANCE_RECONCILIATION_ANALYST')) THEN
    RAISE EXCEPTION 'An unrelated canonical role fiscal-reporting binding changed unexpectedly.';
  END IF;

  IF EXISTS (
    SELECT role_id,permission_id FROM identity.role_permissions
    WHERE binding_status='ACTIVE'
    GROUP BY role_id,permission_id HAVING count(*)>1) THEN
    RAISE EXCEPTION 'Duplicate ACTIVE role-permission bindings exist.';
  END IF;
END $$;

SELECT role_code,role_name,role_provenance,role_status,is_privileged,
       requires_elevated_approval,direct_add_user_eligible,human_assignable
FROM identity.roles
WHERE role_provenance IN ('CANONICAL_ROLE','HISTORICAL_LEGACY_ROLE','SERVICE_ROLE')
ORDER BY role_provenance,role_code;
