\set ON_ERROR_STOP on

DO $$
DECLARE
  expected_roles constant text[] := ARRAY[
    'APT_CASHIER_OPERATOR','COMPLIANCE_POLICY_ADMINISTRATOR','EXECUTIVE_MANAGEMENT',
    'FINANCE_RECONCILIATION_ANALYST','OPERATIONS_SUPERVISOR','PARKING_ATTENDANT',
    'SITE_OPERATOR','SYSTEM_ADMINISTRATOR'];
  obsolete_roles constant text[] := ARRAY[
    'SYSTEM_ADMIN','SYSTEM_RBAC_ADMINISTRATOR','PLATFORM_ADMINISTRATOR',
    'OPERATIONS_MANAGER','SUPPORT_AGENT','COMPLIANCE_REVIEWER',
    'HEAD_OFFICE_STATUTORY_BENEFIT_REVIEWER','MERCHANT_ADMIN','SECURITY_REVIEWER',
    'FINANCE_RECONCILIATION','OPERATOR_SUPPORT_STAFF'];
  operations_supervisor_permissions constant text[] := ARRAY[
    'statutory-discounts.session.lookup','statutory-discounts.draft.view',
    'statutory-discounts.draft.create','statutory-discounts.evidence.view',
    'statutory-discounts.evidence.capture','statutory-discounts.review.queue.read',
    'statutory-discounts.review.detail.read','statutory-discounts.evidence.review.view',
    'statutory-discounts.decision.review','statutory-discounts.decision.approve',
    'statutory-discounts.decision.reject','statutory-discounts.policy.resolve',
    'fiscal-issuance.status.read','fiscal-issuance.void.command',
    'operator-workflow-audit.view','projection-health.view',
    'vendor-acknowledgments.view','ticket.lookup','shift.view','shift.manage'];
  site_operator_permissions constant text[] := ARRAY[
    'statutory-discounts.session.lookup','statutory-discounts.draft.view',
    'statutory-discounts.draft.create','statutory-discounts.evidence.view',
    'statutory-discounts.evidence.capture','statutory-discounts.policy.resolve',
    'fiscal-issuance.status.read','ticket.lookup'];
  finance_permissions constant text[] := ARRAY[
    'reconciliation.view','payment-report.view','fiscal-report.view',
    'sales-invoice-report.view','statutory-discount-report.view','revenue-report.view',
    'variance-report.view','reports.view','reports.export','fiscal-reporting.ej.read',
    'fiscal-reporting.ej.export','fiscal-reporting.x.read','fiscal-reporting.x.generate',
    'fiscal-reporting.z.read'];
  compliance_permissions constant text[] := ARRAY[
    'statutory-discounts.audit.read','fiscal-issuance.void.audit.read',
    'fiscal-view-audit.read','audit-report.view','compliance-report.view',
    'policy-import.submit','policy-import.review','policy-import.approve','policy-import.manage',
    'operator-console.policy-import-review.submit','operator-console.policy-import-review.view-own',
    'operator-console.policy-import-review.review','operator-console.policy-import-review.manage',
    'operator-console.policy-import-review.approve.legal',
    'operator-console.policy-import-review.approve.ops',
    'operator-console.policy-import-review.approve.qa',
    'operator-console.policy-import-review.approve.db',
    'statutory-discount-policy.view','statutory-discount-policy.manage',
    'evidence-rule-policy.view','evidence-rule-policy.manage','reports.export'];
  executive_permissions constant text[] := ARRAY[
    'dashboard.view','reports.view','executive-summary.view','site-performance.view',
    'site-group-performance.view','revenue-summary.view','payment-summary.view',
    'fiscal-summary.view','statutory-discount-summary.view','exception-trend.view',
    'operational-monitoring.view'];
  actual_roles text[];
BEGIN
  SELECT array_agg(role_code ORDER BY role_code) INTO actual_roles
  FROM identity.roles
  WHERE human_assignable AND role_status='ACTIVE'
    AND effective_from<=now() AND (effective_to IS NULL OR effective_to>now());
  IF actual_roles IS DISTINCT FROM expected_roles THEN
    RAISE EXCEPTION 'Expected approved active role catalog %, found %.', expected_roles, actual_roles;
  END IF;

  IF EXISTS (
    SELECT 1 FROM identity.roles
    WHERE role_code=ANY(expected_roles)
      AND (role_provenance<>'CANONICAL_ROLE' OR role_status<>'ACTIVE' OR NOT human_assignable)
  ) THEN
    RAISE EXCEPTION 'An approved role is not active, canonical, and human-assignable.';
  END IF;
  IF EXISTS (
    SELECT 1 FROM identity.roles
    WHERE role_code=ANY(obsolete_roles)
      AND (role_status<>'RETIRED' OR human_assignable OR direct_add_user_eligible OR effective_to IS NULL)
  ) THEN
    RAISE EXCEPTION 'A superseded role is still active or assignable.';
  END IF;
  IF EXISTS (
    SELECT 1 FROM identity.role_permissions rp
    JOIN identity.roles r ON r.role_id=rp.role_id
    WHERE r.role_code=ANY(obsolete_roles) AND rp.binding_status='ACTIVE'
  ) THEN
    RAISE EXCEPTION 'A superseded role still has an ACTIVE permission binding.';
  END IF;

  IF (SELECT count(*) FROM identity.role_user_type_compatibility c
      JOIN identity.roles r ON r.role_id=c.role_id
      WHERE r.role_code=ANY(expected_roles))<>8
     OR EXISTS (
      SELECT 1 FROM identity.role_user_type_compatibility c
      JOIN identity.roles r ON r.role_id=c.role_id
      WHERE r.role_code=ANY(obsolete_roles)) THEN
    RAISE EXCEPTION 'Approved role/user-type compatibility is incomplete or obsolete compatibility remains.';
  END IF;

  IF (SELECT count(*) FROM identity.role_permissions rp
      JOIN identity.roles r ON r.role_id=rp.role_id
      WHERE r.role_code='SYSTEM_ADMINISTRATOR' AND rp.binding_status='ACTIVE')<>34
     OR EXISTS (
      SELECT 1 FROM identity.role_permissions rp
      JOIN identity.roles r ON r.role_id=rp.role_id
      JOIN identity.permissions p ON p.permission_id=rp.permission_id
      WHERE r.role_code='SYSTEM_ADMINISTRATOR' AND rp.binding_status='ACTIVE'
        AND p.permission_domain NOT IN
          ('management-platform','administration','identity','human-authentication','platform-config'))
     OR EXISTS (
      SELECT 1 FROM identity.role_permissions rp
      JOIN identity.roles r ON r.role_id=rp.role_id
      JOIN identity.permissions p ON p.permission_id=rp.permission_id
      WHERE r.role_code='SYSTEM_ADMINISTRATOR' AND rp.binding_status='ACTIVE'
        AND (p.permission_code LIKE 'statutory-discounts.%'
          OR p.permission_code LIKE 'reconciliation.%'
          OR p.permission_code LIKE 'policy-import.%'
          OR p.permission_code LIKE 'apt.%'
          OR p.permission_code LIKE 'parking-attendant.%')) THEN
    RAISE EXCEPTION 'System Administrator is not restricted to its 34 administrative permissions.';
  END IF;

  IF (SELECT array_agg(p.permission_code::text ORDER BY p.permission_code)
      FROM identity.role_permissions rp
      JOIN identity.roles r ON r.role_id=rp.role_id
      JOIN identity.permissions p ON p.permission_id=rp.permission_id
      WHERE r.role_code='OPERATIONS_SUPERVISOR' AND rp.binding_status='ACTIVE')
       IS DISTINCT FROM (SELECT array_agg(code ORDER BY code) FROM unnest(operations_supervisor_permissions) code)
  THEN
    RAISE EXCEPTION 'Operations Supervisor permission bundle does not match the approved 20 permissions.';
  END IF;

  IF (SELECT array_agg(p.permission_code::text ORDER BY p.permission_code)
      FROM identity.role_permissions rp
      JOIN identity.roles r ON r.role_id=rp.role_id
      JOIN identity.permissions p ON p.permission_id=rp.permission_id
      WHERE r.role_code='SITE_OPERATOR' AND rp.binding_status='ACTIVE')
       IS DISTINCT FROM (SELECT array_agg(code ORDER BY code) FROM unnest(site_operator_permissions) code)
  THEN
    RAISE EXCEPTION 'Site Operator permission bundle does not match the approved eight permissions.';
  END IF;

  IF (SELECT count(*) FROM identity.role_permissions rp
      JOIN identity.roles r ON r.role_id=rp.role_id
      JOIN identity.permissions p ON p.permission_id=rp.permission_id
      WHERE r.role_code='PARKING_ATTENDANT' AND rp.binding_status='ACTIVE'
        AND p.permission_code='parking-attendant.operate')<>1
     OR (SELECT count(*) FROM identity.role_permissions rp JOIN identity.roles r ON r.role_id=rp.role_id
         WHERE r.role_code='PARKING_ATTENDANT' AND rp.binding_status='ACTIVE')<>1
     OR (SELECT count(*) FROM identity.role_permissions rp
         JOIN identity.roles r ON r.role_id=rp.role_id
         JOIN identity.permissions p ON p.permission_id=rp.permission_id
         WHERE r.role_code='APT_CASHIER_OPERATOR' AND rp.binding_status='ACTIVE'
           AND p.permission_code='apt.cashier.operate')<>1
     OR (SELECT count(*) FROM identity.role_permissions rp JOIN identity.roles r ON r.role_id=rp.role_id
         WHERE r.role_code='APT_CASHIER_OPERATOR' AND rp.binding_status='ACTIVE')<>1 THEN
    RAISE EXCEPTION 'Parking Attendant or APT / Cashier Operator has an incorrect permission bundle.';
  END IF;

  IF (SELECT array_agg(p.permission_code::text ORDER BY p.permission_code)
      FROM identity.role_permissions rp
      JOIN identity.roles r ON r.role_id=rp.role_id
      JOIN identity.permissions p ON p.permission_id=rp.permission_id
      WHERE r.role_code='FINANCE_RECONCILIATION_ANALYST' AND rp.binding_status='ACTIVE')
       IS DISTINCT FROM (SELECT array_agg(code ORDER BY code) FROM unnest(finance_permissions) code)
     OR (SELECT array_agg(p.permission_code::text ORDER BY p.permission_code)
      FROM identity.role_permissions rp
      JOIN identity.roles r ON r.role_id=rp.role_id
      JOIN identity.permissions p ON p.permission_id=rp.permission_id
      WHERE r.role_code='COMPLIANCE_POLICY_ADMINISTRATOR' AND rp.binding_status='ACTIVE')
       IS DISTINCT FROM (SELECT array_agg(code ORDER BY code) FROM unnest(compliance_permissions) code)
  THEN
    RAISE EXCEPTION 'Finance or Compliance permission bundle does not match the approved catalog.';
  END IF;

  IF (SELECT array_agg(p.permission_code::text ORDER BY p.permission_code)
      FROM identity.role_permissions rp
      JOIN identity.roles r ON r.role_id=rp.role_id
      JOIN identity.permissions p ON p.permission_id=rp.permission_id
      WHERE r.role_code='EXECUTIVE_MANAGEMENT' AND rp.binding_status='ACTIVE')
       IS DISTINCT FROM (SELECT array_agg(code ORDER BY code) FROM unnest(executive_permissions) code)
     OR EXISTS (
      SELECT 1 FROM identity.role_permissions rp
      JOIN identity.roles r ON r.role_id=rp.role_id
      JOIN identity.permissions p ON p.permission_id=rp.permission_id
      WHERE r.role_code='EXECUTIVE_MANAGEMENT' AND rp.binding_status='ACTIVE'
        AND p.permission_action NOT IN ('read','view','lookup')) THEN
    RAISE EXCEPTION 'Executive / Management is not the approved read-only bundle.';
  END IF;

  IF EXISTS (
    SELECT 1 FROM identity.user_role_scope_grants sg
    JOIN identity.user_roles ur ON ur.user_role_id=sg.user_role_id
    JOIN identity.roles r ON r.role_id=ur.role_id
    WHERE sg.grant_status IN ('PENDING','ACTIVE','SUSPENDED')
      AND ((r.role_code IN ('SYSTEM_ADMINISTRATOR','EXECUTIVE_MANAGEMENT') AND sg.scope_type<>'GLOBAL')
        OR (r.role_code IN ('OPERATIONS_SUPERVISOR','SITE_OPERATOR','PARKING_ATTENDANT','APT_CASHIER_OPERATOR')
            AND sg.scope_type<>'SITE')
        OR r.role_code=ANY(obsolete_roles))
  ) THEN
    RAISE EXCEPTION 'An invalid approved-role/scope or obsolete-role/scope combination remains current.';
  END IF;

  IF EXISTS (
    SELECT role_id,permission_id FROM identity.role_permissions
    WHERE binding_status='ACTIVE'
    GROUP BY role_id,permission_id HAVING count(*)>1
  ) THEN
    RAISE EXCEPTION 'Duplicate ACTIVE role-permission bindings exist.';
  END IF;
END $$;

SELECT r.role_code,r.role_name,r.role_status,r.role_provenance,
       count(rp.role_permission_id) FILTER (WHERE rp.binding_status='ACTIVE') AS active_permission_count
FROM identity.roles r
LEFT JOIN identity.role_permissions rp ON rp.role_id=r.role_id
WHERE r.role_code IN (
  'SYSTEM_ADMINISTRATOR','OPERATIONS_SUPERVISOR','SITE_OPERATOR','PARKING_ATTENDANT',
  'APT_CASHIER_OPERATOR','FINANCE_RECONCILIATION_ANALYST',
  'COMPLIANCE_POLICY_ADMINISTRATOR','EXECUTIVE_MANAGEMENT')
GROUP BY r.role_code,r.role_name,r.role_status,r.role_provenance
ORDER BY r.role_code;
