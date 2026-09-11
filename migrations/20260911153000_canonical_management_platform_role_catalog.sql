-- Wave 3 canonical Management Platform role catalog and compatibility boundary.
-- Existing UAT assignments remain active on renamed UAT roles until separately reconciled.
BEGIN;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid=t.typnamespace
    WHERE n.nspname='identity' AND t.typname='role_provenance_enum'
  ) THEN
    CREATE TYPE identity.role_provenance_enum AS ENUM
      ('CANONICAL_ROLE','HISTORICAL_LEGACY_ROLE','UAT_TEST_ROLE','SERVICE_ROLE');
  END IF;
END $$;

ALTER TABLE identity.roles
  ADD COLUMN IF NOT EXISTS role_provenance identity.role_provenance_enum
    NOT NULL DEFAULT 'HISTORICAL_LEGACY_ROLE',
  ADD COLUMN IF NOT EXISTS direct_add_user_eligible boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS human_assignable boolean NOT NULL DEFAULT true;

CREATE TABLE IF NOT EXISTS identity.role_user_type_compatibility (
  role_id uuid NOT NULL,
  user_type identity.user_type_enum NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by_service_identity_id uuid NULL,
  CONSTRAINT pk_role_user_type_compatibility PRIMARY KEY (role_id,user_type),
  CONSTRAINT fk_role_user_type_compatibility__role_id FOREIGN KEY (role_id)
    REFERENCES identity.roles(role_id) ON DELETE RESTRICT
);

-- Preserve the previous local/UAT role objects and their active assignments.
UPDATE identity.roles
SET role_code='UAT_'||role_code,
    role_name='UAT '||role_name,
    role_provenance='UAT_TEST_ROLE',
    direct_add_user_eligible=false,
    human_assignable=false,
    updated_at=now(),
    row_version=row_version+1
WHERE created_by_service_identity_id='79000000-0000-0000-0000-000000000003'
  AND role_code IN (
    'SYSTEM_RBAC_ADMINISTRATOR','PLATFORM_ADMINISTRATOR','OPERATIONS_SUPERVISOR',
    'OPERATOR_SUPPORT_STAFF','FINANCE_RECONCILIATION_ANALYST',
    'COMPLIANCE_POLICY_ADMINISTRATOR','EXECUTIVE_MANAGEMENT')
  AND NOT EXISTS (
    SELECT 1 FROM identity.roles collision
    WHERE collision.role_code='UAT_'||identity.roles.role_code
  );

CREATE OR REPLACE FUNCTION pg_temp.exitpass_wave3_uuid(input text)
RETURNS uuid LANGUAGE sql IMMUTABLE AS $fn$
  SELECT (substr(md5(input),1,8)||'-'||substr(md5(input),9,4)||'-'||
          substr(md5(input),13,4)||'-'||substr(md5(input),17,4)||'-'||
          substr(md5(input),21,12))::uuid
$fn$;

CREATE TEMP TABLE wave3_roles (
  role_code varchar(64) PRIMARY KEY, role_name varchar(128) NOT NULL,
  role_description text NOT NULL, role_type identity.role_type_enum NOT NULL,
  role_provenance identity.role_provenance_enum NOT NULL,
  role_status identity.role_status_enum NOT NULL, is_privileged boolean NOT NULL,
  requires_elevated_approval boolean NOT NULL,
  direct_add_user_eligible boolean NOT NULL, human_assignable boolean NOT NULL
) ON COMMIT DROP;

INSERT INTO wave3_roles VALUES
('SYSTEM_ADMIN','System Administrator','Emergency break-glass administration only.','SYSTEM','CANONICAL_ROLE','ACTIVE',true,true,false,true),
('SYSTEM_RBAC_ADMINISTRATOR','System / RBAC Administrator','Identity, role, permission, scope, session, and MFA administration.','SYSTEM','CANONICAL_ROLE','ACTIVE',true,true,false,true),
('PLATFORM_ADMINISTRATOR','Platform Administrator','Site, Site Group, device, POS/fiscal configuration, connector, and platform administration.','OPERATIONS','CANONICAL_ROLE','ACTIVE',true,true,false,true),
('OPERATIONS_MANAGER','Operations Manager','Governed operational management without finance reconciliation administration.','OPERATIONS','CANONICAL_ROLE','ACTIVE',true,true,false,true),
('OPERATIONS_SUPERVISOR','Operations Supervisor','Operational and statutory review without payable-basis application or fiscal-void command authority.','OPERATIONS','CANONICAL_ROLE','ACTIVE',true,true,false,true),
('SITE_OPERATOR','Site Operator','Site-scoped parking operations.','OPERATIONS','CANONICAL_ROLE','ACTIVE',false,false,true,true),
('SUPPORT_AGENT','Support Agent','Read-oriented support and operational diagnosis without payment or statutory-decision mutation.','SUPPORT','CANONICAL_ROLE','ACTIVE',false,false,true,true),
('FINANCE_RECONCILIATION_ANALYST','Finance / Reconciliation Analyst','Financial reporting and reconciliation analysis without payment finalization.','FINANCE','CANONICAL_ROLE','ACTIVE',false,false,true,true),
('COMPLIANCE_REVIEWER','Compliance Reviewer','Compliance and restricted-evidence review.','COMPLIANCE','CANONICAL_ROLE','ACTIVE',true,true,false,true),
('COMPLIANCE_POLICY_ADMINISTRATOR','Compliance / Policy Administrator','Compliance policy, evidence-rule, and policy-import administration.','COMPLIANCE','CANONICAL_ROLE','ACTIVE',true,true,false,true),
('HEAD_OFFICE_STATUTORY_BENEFIT_REVIEWER','Head Office Statutory Benefit Reviewer','Statutory-benefit queue, evidence, approval, and rejection only.','COMPLIANCE','CANONICAL_ROLE','ACTIVE',true,true,false,true),
('EXECUTIVE_MANAGEMENT','Executive / Management','Read-only dashboards, summaries, KPI, performance, and management reporting.','OTHER','CANONICAL_ROLE','ACTIVE',false,false,true,true),
('MERCHANT_ADMIN','Merchant Administrator','Merchant coupon administration.','MERCHANT','CANONICAL_ROLE','ACTIVE',false,false,true,true),
('SECURITY_REVIEWER','Security Reviewer','Review-oriented identity, session, evidence, and access-audit visibility.','SECURITY','CANONICAL_ROLE','ACTIVE',true,true,false,true),
('FINANCE_RECONCILIATION','Finance Reconciliation','Historical finance role retained only for migration evidence.','FINANCE','HISTORICAL_LEGACY_ROLE','RETIRED',false,false,false,false),
('OPERATOR_SUPPORT_STAFF','Operator / Support Staff','Historical combined operator/support role retained only for migration evidence.','SUPPORT','HISTORICAL_LEGACY_ROLE','RETIRED',false,false,false,false),
('SERVICE_PRINCIPAL','Service Principal','Non-human service identity role.','SERVICE','SERVICE_ROLE','ACTIVE',false,false,false,false);

INSERT INTO identity.roles (
  role_id,role_code,role_name,role_description,role_type,role_provenance,
  role_status,is_privileged,requires_elevated_approval,direct_add_user_eligible,
  human_assignable,effective_from,created_by_service_identity_id,
  updated_by_service_identity_id)
SELECT pg_temp.exitpass_wave3_uuid('wave3:canonical-role:'||role_code),role_code,
  role_name,role_description,role_type,role_provenance,role_status,is_privileged,
  requires_elevated_approval,direct_add_user_eligible,human_assignable,
  '2020-01-01T00:00:00Z','1f2ffdfb-c4a9-5a00-a656-9f3a132b1978',
  '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
FROM wave3_roles
ON CONFLICT ON CONSTRAINT uq_roles__role_code DO UPDATE SET
  role_name=EXCLUDED.role_name,role_description=EXCLUDED.role_description,
  role_type=EXCLUDED.role_type,role_provenance=EXCLUDED.role_provenance,
  role_status=CASE
    WHEN EXCLUDED.role_provenance='HISTORICAL_LEGACY_ROLE' AND EXISTS (
      SELECT 1 FROM identity.user_roles ur
      WHERE ur.role_id=identity.roles.role_id AND ur.assignment_status='ACTIVE')
    THEN identity.roles.role_status ELSE EXCLUDED.role_status END,
  is_privileged=EXCLUDED.is_privileged,
  requires_elevated_approval=EXCLUDED.requires_elevated_approval,
  direct_add_user_eligible=EXCLUDED.direct_add_user_eligible,
  human_assignable=EXCLUDED.human_assignable,effective_to=NULL,
  updated_at=now(),row_version=identity.roles.row_version+1
WHERE (identity.roles.role_name,identity.roles.role_description,identity.roles.role_type,
       identity.roles.role_provenance,identity.roles.role_status,identity.roles.is_privileged,
       identity.roles.requires_elevated_approval,identity.roles.direct_add_user_eligible,
       identity.roles.human_assignable,identity.roles.effective_to)
  IS DISTINCT FROM
      (EXCLUDED.role_name,EXCLUDED.role_description,EXCLUDED.role_type,
       EXCLUDED.role_provenance,
       CASE
         WHEN EXCLUDED.role_provenance='HISTORICAL_LEGACY_ROLE' AND EXISTS (
           SELECT 1 FROM identity.user_roles ur
           WHERE ur.role_id=identity.roles.role_id AND ur.assignment_status='ACTIVE')
         THEN identity.roles.role_status ELSE EXCLUDED.role_status END,
       EXCLUDED.is_privileged,EXCLUDED.requires_elevated_approval,
       EXCLUDED.direct_add_user_eligible,EXCLUDED.human_assignable,NULL);

CREATE TEMP TABLE wave3_compatibility (
  role_code varchar(64), user_type identity.user_type_enum,
  PRIMARY KEY(role_code,user_type)
) ON COMMIT DROP;
INSERT INTO wave3_compatibility VALUES
('SYSTEM_RBAC_ADMINISTRATOR','INTERNAL_ADMIN'),('PLATFORM_ADMINISTRATOR','INTERNAL_ADMIN'),('SYSTEM_ADMIN','INTERNAL_ADMIN'),
('OPERATIONS_MANAGER','OPERATIONS_USER'),('OPERATIONS_SUPERVISOR','OPERATIONS_USER'),
('SITE_OPERATOR','SITE_OPERATOR'),('SUPPORT_AGENT','SUPPORT_USER'),
('FINANCE_RECONCILIATION_ANALYST','FINANCE_USER'),
('COMPLIANCE_REVIEWER','COMPLIANCE_USER'),('COMPLIANCE_POLICY_ADMINISTRATOR','COMPLIANCE_USER'),
('HEAD_OFFICE_STATUTORY_BENEFIT_REVIEWER','COMPLIANCE_USER'),
('MERCHANT_ADMIN','MERCHANT_USER'),('SECURITY_REVIEWER','SECURITY_USER'),
('EXECUTIVE_MANAGEMENT','OTHER');

DELETE FROM identity.role_user_type_compatibility c
USING identity.roles r
WHERE r.role_id=c.role_id AND r.role_provenance='CANONICAL_ROLE'
  AND NOT EXISTS (
    SELECT 1 FROM wave3_compatibility desired
    WHERE desired.role_code=r.role_code AND desired.user_type=c.user_type);
INSERT INTO identity.role_user_type_compatibility(role_id,user_type,created_by_service_identity_id)
SELECT r.role_id,c.user_type,'1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
FROM wave3_compatibility c JOIN identity.roles r ON r.role_code=c.role_code
ON CONFLICT DO NOTHING;

CREATE TEMP TABLE wave3_role_permissions (
  role_code varchar(64), permission_code varchar(96),
  PRIMARY KEY(role_code,permission_code)
) ON COMMIT DROP;
INSERT INTO wave3_role_permissions VALUES
('SYSTEM_RBAC_ADMINISTRATOR','management-platform.identity-rbac.inventory.read'),
('SYSTEM_RBAC_ADMINISTRATOR','user.view'),('SYSTEM_RBAC_ADMINISTRATOR','user.manage'),
('SYSTEM_RBAC_ADMINISTRATOR','rbac.view'),('SYSTEM_RBAC_ADMINISTRATOR','rbac.manage'),
('SYSTEM_RBAC_ADMINISTRATOR','role.view'),('SYSTEM_RBAC_ADMINISTRATOR','role.manage'),
('SYSTEM_RBAC_ADMINISTRATOR','permission.view'),('SYSTEM_RBAC_ADMINISTRATOR','permission.manage'),
('SYSTEM_RBAC_ADMINISTRATOR','assignment.view'),('SYSTEM_RBAC_ADMINISTRATOR','assignment.manage'),
('SYSTEM_RBAC_ADMINISTRATOR','access-audit.view'),
('SYSTEM_RBAC_ADMINISTRATOR','identity.role-assignment.manage'),('SYSTEM_RBAC_ADMINISTRATOR','identity.scope-assignment.manage'),
('SYSTEM_RBAC_ADMINISTRATOR','identity.privileged-access.decide'),('SYSTEM_RBAC_ADMINISTRATOR','identity.access-review.manage'),
('SYSTEM_RBAC_ADMINISTRATOR','human-authentication.session.admin.view'),('SYSTEM_RBAC_ADMINISTRATOR','human-authentication.session.admin.revoke'),
('SYSTEM_RBAC_ADMINISTRATOR','human-authentication.credential.reset'),('SYSTEM_RBAC_ADMINISTRATOR','human-authentication.mfa.status.view'),
('SYSTEM_RBAC_ADMINISTRATOR','human-authentication.mfa.reset'),('SYSTEM_RBAC_ADMINISTRATOR','human-authentication.mfa.remove'),
('PLATFORM_ADMINISTRATOR','site.view'),('PLATFORM_ADMINISTRATOR','site.manage'),
('PLATFORM_ADMINISTRATOR','site-group.view'),('PLATFORM_ADMINISTRATOR','site-group.manage'),
('PLATFORM_ADMINISTRATOR','device.view'),('PLATFORM_ADMINISTRATOR','device.manage'),
('PLATFORM_ADMINISTRATOR','device-binding.view'),('PLATFORM_ADMINISTRATOR','device-binding.manage'),
('PLATFORM_ADMINISTRATOR','shift.view'),('PLATFORM_ADMINISTRATOR','shift.manage'),
('PLATFORM_ADMINISTRATOR','pos-server-config.view'),('PLATFORM_ADMINISTRATOR','pos-server-config.manage'),
('PLATFORM_ADMINISTRATOR','connector-config.view'),('PLATFORM_ADMINISTRATOR','connector-config.manage'),
('PLATFORM_ADMINISTRATOR','operational-monitoring.view'),('PLATFORM_ADMINISTRATOR','platform-config.view'),
('PLATFORM_ADMINISTRATOR','platform-config.manage'),('PLATFORM_ADMINISTRATOR','environment-config.view'),
('OPERATIONS_MANAGER','sessions.resolve'),('OPERATIONS_MANAGER','tariffs.quote'),
('OPERATIONS_MANAGER','gate.consume_authorization'),('OPERATIONS_MANAGER','gate.record_event'),
('OPERATIONS_MANAGER','operations.manual_gate'),('OPERATIONS_MANAGER','audit.read'),
('OPERATIONS_MANAGER','fiscal-issuance.status.read'),('OPERATIONS_MANAGER','operational-monitoring.view'),
('OPERATIONS_MANAGER','projection-health.view'),('OPERATIONS_MANAGER','ops.vendor-session-projection-health.view'),
('OPERATIONS_MANAGER','vendor-acknowledgments.view'),
('OPERATIONS_SUPERVISOR','statutory-discounts.review.queue.read'),
('OPERATIONS_SUPERVISOR','statutory-discounts.review.detail.read'),
('OPERATIONS_SUPERVISOR','statutory-discounts.evidence.review.view'),
('OPERATIONS_SUPERVISOR','statutory-discounts.decision.review'),
('OPERATIONS_SUPERVISOR','statutory-discounts.decision.approve'),
('OPERATIONS_SUPERVISOR','statutory-discounts.decision.reject'),
('OPERATIONS_SUPERVISOR','statutory-discounts.policy.resolve'),
('OPERATIONS_SUPERVISOR','fiscal-issuance.status.read'),
('OPERATIONS_SUPERVISOR','operator-workflow-audit.view'),('OPERATIONS_SUPERVISOR','projection-health.view'),
('OPERATIONS_SUPERVISOR','ops.vendor-session-projection-health.view'),('OPERATIONS_SUPERVISOR','vendor-acknowledgments.view'),
('SITE_OPERATOR','sessions.resolve'),('SITE_OPERATOR','gate.consume_authorization'),
('SITE_OPERATOR','gate.record_event'),('SITE_OPERATOR','operations.manual_gate'),
('SITE_OPERATOR','apt.access'),('SITE_OPERATOR','cashier-shifts.operate'),
('SITE_OPERATOR','cash-custody.operate'),('SITE_OPERATOR','terminal-cash.receive'),
('SUPPORT_AGENT','sessions.resolve'),('SUPPORT_AGENT','tariffs.quote'),
('SUPPORT_AGENT','ticket.lookup'),('SUPPORT_AGENT','projection-health.view'),
('SUPPORT_AGENT','ops.vendor-session-projection-health.view'),
('SUPPORT_AGENT','operator-console.vendor-projection-health.view'),
('SUPPORT_AGENT','vendor-acknowledgments.view'),('SUPPORT_AGENT','audit.read'),
('FINANCE_RECONCILIATION_ANALYST','reconciliation.view'),
('FINANCE_RECONCILIATION_ANALYST','payment-report.view'),
('FINANCE_RECONCILIATION_ANALYST','fiscal-report.view'),
('FINANCE_RECONCILIATION_ANALYST','sales-invoice-report.view'),
('FINANCE_RECONCILIATION_ANALYST','statutory-discount-report.view'),
('FINANCE_RECONCILIATION_ANALYST','revenue-report.view'),
('FINANCE_RECONCILIATION_ANALYST','variance-report.view'),
('FINANCE_RECONCILIATION_ANALYST','reports.view'),
('FINANCE_RECONCILIATION_ANALYST','reports.export'),
('FINANCE_RECONCILIATION_ANALYST','fiscal-reporting.ej.read'),
('FINANCE_RECONCILIATION_ANALYST','fiscal-reporting.ej.export'),
('FINANCE_RECONCILIATION_ANALYST','fiscal-reporting.x.read'),
('FINANCE_RECONCILIATION_ANALYST','fiscal-reporting.x.generate'),
('FINANCE_RECONCILIATION_ANALYST','fiscal-reporting.z.read'),
('COMPLIANCE_REVIEWER','statutory-discounts.review.queue.read'),
('COMPLIANCE_REVIEWER','statutory-discounts.review.detail.read'),
('COMPLIANCE_REVIEWER','statutory-discounts.evidence.review.view'),
('COMPLIANCE_REVIEWER','statutory-discounts.audit.read'),
('COMPLIANCE_REVIEWER','audit.read'),('COMPLIANCE_REVIEWER','evidence.read_restricted'),
('COMPLIANCE_REVIEWER','compliance-report.view'),
('COMPLIANCE_POLICY_ADMINISTRATOR','statutory-discounts.audit.read'),
('COMPLIANCE_POLICY_ADMINISTRATOR','fiscal-issuance.void.audit.read'),
('COMPLIANCE_POLICY_ADMINISTRATOR','fiscal-view-audit.read'),
('COMPLIANCE_POLICY_ADMINISTRATOR','audit-report.view'),
('COMPLIANCE_POLICY_ADMINISTRATOR','compliance-report.view'),
('COMPLIANCE_POLICY_ADMINISTRATOR','policy-import.submit'),
('COMPLIANCE_POLICY_ADMINISTRATOR','policy-import.review'),
('COMPLIANCE_POLICY_ADMINISTRATOR','policy-import.approve'),
('COMPLIANCE_POLICY_ADMINISTRATOR','policy-import.manage'),
('COMPLIANCE_POLICY_ADMINISTRATOR','operator-console.policy-import-review.submit'),
('COMPLIANCE_POLICY_ADMINISTRATOR','operator-console.policy-import-review.view-own'),
('COMPLIANCE_POLICY_ADMINISTRATOR','operator-console.policy-import-review.review'),
('COMPLIANCE_POLICY_ADMINISTRATOR','operator-console.policy-import-review.manage'),
('COMPLIANCE_POLICY_ADMINISTRATOR','operator-console.policy-import-review.approve.legal'),
('COMPLIANCE_POLICY_ADMINISTRATOR','operator-console.policy-import-review.approve.ops'),
('COMPLIANCE_POLICY_ADMINISTRATOR','operator-console.policy-import-review.approve.qa'),
('COMPLIANCE_POLICY_ADMINISTRATOR','operator-console.policy-import-review.approve.db'),
('COMPLIANCE_POLICY_ADMINISTRATOR','statutory-discount-policy.view'),
('COMPLIANCE_POLICY_ADMINISTRATOR','statutory-discount-policy.manage'),
('COMPLIANCE_POLICY_ADMINISTRATOR','evidence-rule-policy.view'),
('COMPLIANCE_POLICY_ADMINISTRATOR','evidence-rule-policy.manage'),
('COMPLIANCE_POLICY_ADMINISTRATOR','reports.export'),
('HEAD_OFFICE_STATUTORY_BENEFIT_REVIEWER','statutory-discounts.review.queue.read'),
('HEAD_OFFICE_STATUTORY_BENEFIT_REVIEWER','statutory-discounts.review.detail.read'),
('HEAD_OFFICE_STATUTORY_BENEFIT_REVIEWER','statutory-discounts.evidence.review.view'),
('HEAD_OFFICE_STATUTORY_BENEFIT_REVIEWER','statutory-discounts.decision.approve'),
('HEAD_OFFICE_STATUTORY_BENEFIT_REVIEWER','statutory-discounts.decision.reject'),
('EXECUTIVE_MANAGEMENT','dashboard.view'),('EXECUTIVE_MANAGEMENT','reports.view'),
('EXECUTIVE_MANAGEMENT','executive-summary.view'),('EXECUTIVE_MANAGEMENT','site-performance.view'),
('EXECUTIVE_MANAGEMENT','site-group-performance.view'),('EXECUTIVE_MANAGEMENT','revenue-summary.view'),
('EXECUTIVE_MANAGEMENT','payment-summary.view'),('EXECUTIVE_MANAGEMENT','fiscal-summary.view'),
('EXECUTIVE_MANAGEMENT','statutory-discount-summary.view'),('EXECUTIVE_MANAGEMENT','exception-trend.view'),
('EXECUTIVE_MANAGEMENT','operational-monitoring.view'),
('MERCHANT_ADMIN','coupons.manage'),('MERCHANT_ADMIN','coupons.apply'),('MERCHANT_ADMIN','audit.read'),
('SECURITY_REVIEWER','audit.read'),('SECURITY_REVIEWER','evidence.read_restricted'),
('SECURITY_REVIEWER','user.view'),('SECURITY_REVIEWER','rbac.view'),
('SECURITY_REVIEWER','role.view'),('SECURITY_REVIEWER','permission.view'),
('SECURITY_REVIEWER','assignment.view'),('SECURITY_REVIEWER','access-audit.view'),
('SECURITY_REVIEWER','human-authentication.session.admin.view');

-- Ensure every permission required by the reviewed mapping exists. The clean-build
-- reference data supplies the richer names/descriptions; this additive upgrade
-- only creates codes absent from older installations.
INSERT INTO identity.permissions (
  permission_id,permission_code,permission_name,permission_description,
  permission_domain,permission_action,permission_status,is_sensitive,
  requires_audit,created_by_service_identity_id,updated_by_service_identity_id)
SELECT pg_temp.exitpass_wave3_uuid('wave3:permission:'||m.permission_code),
  m.permission_code,initcap(replace(replace(m.permission_code,'.',' '),'-',' ')),
  'Wave 3 canonical permission.',
  split_part(m.permission_code,'.',1),
  reverse(split_part(reverse(m.permission_code),'.',1)),
  'ACTIVE',true,true,'1f2ffdfb-c4a9-5a00-a656-9f3a132b1978',
  '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
FROM (SELECT DISTINCT permission_code FROM wave3_role_permissions) m
ON CONFLICT ON CONSTRAINT uq_permissions__permission_code DO NOTHING;

INSERT INTO wave3_role_permissions
SELECT 'SYSTEM_ADMIN',p.permission_code
FROM identity.permissions p
WHERE p.permission_status='ACTIVE' AND p.permission_code<>'uat-fixture.manage'
ON CONFLICT DO NOTHING;

UPDATE identity.role_permissions rp
SET binding_status='RETIRED',effective_to=now(),
  revocation_reason_code='WAVE3_CANONICAL_PERMISSION_REVIEW',updated_at=now(),
  row_version=rp.row_version+1
FROM identity.roles r
WHERE r.role_id=rp.role_id AND r.role_provenance='CANONICAL_ROLE'
  AND rp.binding_status='ACTIVE'
  AND NOT EXISTS (
    SELECT 1 FROM wave3_role_permissions desired
    WHERE desired.role_code=r.role_code
      AND desired.permission_code=(
        SELECT p.permission_code FROM identity.permissions p
        WHERE p.permission_id=rp.permission_id));

INSERT INTO identity.role_permissions (
  role_permission_id,role_id,permission_id,binding_status,binding_reason_code,
  assigned_by_service_identity_id,effective_from,created_by_service_identity_id,
  updated_by_service_identity_id)
SELECT pg_temp.exitpass_wave3_uuid('wave3:role-permission:'||m.role_code||':'||m.permission_code),
  r.role_id,p.permission_id,'ACTIVE','WAVE3_CANONICAL_PERMISSION_REVIEW',
  '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978','2020-01-01T00:00:00Z',
  '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978',
  '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
FROM wave3_role_permissions m
JOIN identity.roles r ON r.role_code=m.role_code
JOIN identity.permissions p ON p.permission_code=m.permission_code
WHERE NOT EXISTS (
  SELECT 1 FROM identity.role_permissions active
  WHERE active.role_id=r.role_id AND active.permission_id=p.permission_id
    AND active.binding_status='ACTIVE')
ON CONFLICT (role_permission_id) DO UPDATE SET
  binding_status='ACTIVE',effective_to=NULL,revoked_at=NULL,
  revocation_reason_code=NULL,updated_at=now(),
  row_version=identity.role_permissions.row_version+1
WHERE identity.role_permissions.binding_status<>'ACTIVE'
   OR identity.role_permissions.effective_to IS NOT NULL
   OR identity.role_permissions.revoked_at IS NOT NULL
   OR identity.role_permissions.revocation_reason_code IS NOT NULL;

COMMENT ON COLUMN identity.roles.role_provenance IS
  'Authoritative classification: canonical, historical legacy, UAT test, or service.';
COMMENT ON COLUMN identity.roles.direct_add_user_eligible IS
  'True only for canonical roles allowed during direct Add User.';
COMMENT ON COLUMN identity.roles.human_assignable IS
  'False for service, UAT-only, and retired/historical roles.';
COMMENT ON TABLE identity.role_user_type_compatibility IS
  'Database-owned allow-list enforced by Central PMS for every human role assignment.';

COMMIT;
