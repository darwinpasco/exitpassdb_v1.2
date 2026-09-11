-- ExitPass Wave 3 canonical Management Platform human-role catalog.
-- Database-owned provenance, assignment policy, compatibility, and permissions.
-- No user or user-role assignment is created by this clean-build reference data.

BEGIN;
SET CONSTRAINTS ALL DEFERRED;

CREATE OR REPLACE FUNCTION pg_temp.exitpass_wave3_uuid(input text)
RETURNS uuid LANGUAGE sql IMMUTABLE AS $$
    SELECT (substr(md5(input),1,8)||'-'||substr(md5(input),9,4)||'-'||substr(md5(input),13,4)||'-'||substr(md5(input),17,4)||'-'||substr(md5(input),21,12))::uuid
$$;

CREATE TEMP TABLE wave3_roles (
    role_code varchar(64) PRIMARY KEY,
    role_name varchar(128) NOT NULL,
    role_description text NOT NULL,
    role_type identity.role_type_enum NOT NULL,
    role_provenance identity.role_provenance_enum NOT NULL,
    role_status identity.role_status_enum NOT NULL,
    is_privileged boolean NOT NULL,
    requires_elevated_approval boolean NOT NULL,
    direct_add_user_eligible boolean NOT NULL,
    human_assignable boolean NOT NULL
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
    role_id, role_code, role_name, role_description, role_type, role_provenance,
    role_status, is_privileged, requires_elevated_approval,
    direct_add_user_eligible, human_assignable, effective_from,
    created_by_service_identity_id, updated_by_service_identity_id)
SELECT pg_temp.exitpass_wave3_uuid('wave3:canonical-role:'||role_code), role_code, role_name,
       role_description, role_type, role_provenance, role_status, is_privileged,
       requires_elevated_approval, direct_add_user_eligible, human_assignable,
       '2020-01-01T00:00:00Z', '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978',
       '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
FROM wave3_roles
ON CONFLICT ON CONSTRAINT uq_roles__role_code DO UPDATE SET
    role_name=EXCLUDED.role_name, role_description=EXCLUDED.role_description,
    role_type=EXCLUDED.role_type, role_provenance=EXCLUDED.role_provenance,
    role_status=EXCLUDED.role_status, is_privileged=EXCLUDED.is_privileged,
    requires_elevated_approval=EXCLUDED.requires_elevated_approval,
    direct_add_user_eligible=EXCLUDED.direct_add_user_eligible,
    human_assignable=EXCLUDED.human_assignable, effective_to=NULL,
    updated_at=now(), row_version=identity.roles.row_version+1
WHERE (identity.roles.role_name,identity.roles.role_description,identity.roles.role_type,
       identity.roles.role_provenance,identity.roles.role_status,identity.roles.is_privileged,
       identity.roles.requires_elevated_approval,identity.roles.direct_add_user_eligible,
       identity.roles.human_assignable,identity.roles.effective_to)
  IS DISTINCT FROM
      (EXCLUDED.role_name,EXCLUDED.role_description,EXCLUDED.role_type,
       EXCLUDED.role_provenance,EXCLUDED.role_status,EXCLUDED.is_privileged,
       EXCLUDED.requires_elevated_approval,EXCLUDED.direct_add_user_eligible,
       EXCLUDED.human_assignable,NULL);

CREATE TEMP TABLE wave3_permissions (
    permission_code varchar(96) PRIMARY KEY, permission_name varchar(128) NOT NULL,
    permission_description text NOT NULL, permission_domain varchar(64) NOT NULL,
    permission_action varchar(64) NOT NULL, is_sensitive boolean NOT NULL,
    requires_audit boolean NOT NULL
) ON COMMIT DROP;

INSERT INTO wave3_permissions VALUES
('management-platform.identity-rbac.inventory.read','Identity/RBAC inventory read','Read safe identity and RBAC inventory.','management-platform','read',true,true),
('user.view','View users','Read safe user inventory.','administration','view',true,true),
('user.manage','Manage users','Manage human identity profiles and lifecycle.','administration','manage',true,true),
('rbac.view','View RBAC','Read RBAC configuration.','administration','view',true,true),
('rbac.manage','Manage RBAC','Manage governed RBAC configuration.','administration','manage',true,true),
('role.view','View roles','Read role inventory.','administration','view',true,true),
('role.manage','Manage roles','Manage governed roles.','administration','manage',true,true),
('permission.view','View permissions','Read permission inventory.','administration','view',true,true),
('permission.manage','Manage permissions','Manage governed permissions.','administration','manage',true,true),
('assignment.view','View assignments','Read role and scope assignments.','administration','view',true,true),
('assignment.manage','Manage assignments','Manage governed role and scope assignments.','administration','manage',true,true),
('access-audit.view','View access audit','Read access and RBAC audit evidence.','administration','view',true,true),
('site.view','View sites','Read Site inventory.','platform-config','view',false,true),
('site.manage','Manage sites','Manage Sites.','platform-config','manage',true,true),
('site-group.view','View Site Groups','Read Site Group inventory.','platform-config','view',false,true),
('site-group.manage','Manage Site Groups','Manage Site Groups.','platform-config','manage',true,true),
('device.view','View devices','Read device inventory.','platform-config','view',false,true),
('device.manage','Manage devices','Manage devices.','platform-config','manage',true,true),
('device-binding.view','View device bindings','Read device bindings.','platform-config','view',true,true),
('device-binding.manage','Manage device bindings','Manage device bindings.','platform-config','manage',true,true),
('shift.view','View shifts','Read shift inventory.','platform-config','view',true,true),
('shift.manage','Manage shifts','Manage shifts.','platform-config','manage',true,true),
('pos-server-config.view','View POS Server configuration','Read POS/fiscal configuration.','platform-config','view',true,true),
('pos-server-config.manage','Manage POS Server configuration','Manage POS/fiscal configuration.','platform-config','manage',true,true),
('connector-config.view','View connector configuration','Read connector configuration.','platform-config','view',true,true),
('connector-config.manage','Manage connector configuration','Manage connector configuration.','platform-config','manage',true,true),
('platform-config.view','View platform configuration','Read platform configuration.','platform-config','view',true,true),
('platform-config.manage','Manage platform configuration','Manage platform configuration.','platform-config','manage',true,true),
('environment-config.view','View environment configuration','Read safe environment configuration.','platform-config','view',true,true),
('uat-fixture.manage','Manage UAT fixtures','Isolated local/UAT fixture preparation only.','uat-fixture','manage',true,true),
('operational-monitoring.view','View operational monitoring','Read operational monitoring.','monitoring','view',false,true),
('statutory-discounts.session.lookup','Lookup statutory session','Read statutory session context.','statutory-discounts','lookup',false,true),
('statutory-discounts.draft.view','View statutory draft','Read statutory review drafts.','statutory-discounts','view',false,true),
('statutory-discounts.evidence.view','View statutory evidence','Read statutory evidence metadata.','statutory-discounts','view',true,true),
('statutory-discounts.decision.review','Review statutory decision','Review statutory decision context.','statutory-discounts','review',true,true),
('statutory-discounts.decision.approve','Approve statutory decision','Approve a statutory benefit decision.','statutory-discounts','approve',true,true),
('statutory-discounts.decision.reject','Reject statutory decision','Reject a statutory benefit decision.','statutory-discounts','reject',true,true),
('statutory-discounts.policy.resolve','Resolve statutory policy','Read resolved statutory policy.','statutory-discounts','resolve',true,true),
('statutory-discounts.audit.read','Read statutory audit','Read statutory decision audit.','statutory-discounts','read',true,true),
('statutory-discounts.review.queue.read','Read statutory review queue','Read the statutory-benefit review queue.','statutory-discounts','read',true,true),
('statutory-discounts.review.detail.read','Read statutory review detail','Read statutory-benefit review detail.','statutory-discounts','read',true,true),
('statutory-discounts.evidence.review.view','Review statutory evidence','Read evidence needed for statutory-benefit review.','statutory-discounts','view',true,true),
('fiscal-issuance.status.read','Read fiscal issuance status','Read Sales Invoice status.','fiscal','read',false,true),
('fiscal-issuance.void.audit.read','Read fiscal void audit','Read Sales Invoice void audit.','fiscal','read',true,true),
('fiscal-view-audit.read','Read fiscal view audit','Read Sales Invoice view audit.','fiscal','read',true,true),
('ticket.lookup','Lookup ticket','Read ticket and parking session context.','operator-console','lookup',false,true),
('projection-health.view','View projection health','Read projection health.','operator-console','view',false,true),
('ops.vendor-session-projection-health.view','View vendor projection health','Read vendor projection health.','operator-console','view',false,true),
('operator-console.vendor-projection-health.view','View console projection health','Read Operator Console projection health.','operator-console','view',false,true),
('vendor-acknowledgments.view','View vendor acknowledgments','Read vendor acknowledgments.','operator-console','view',false,true),
('operator-workflow-audit.view','View operator workflow audit','Read operator workflow audit.','audit','view',true,true),
('reconciliation.view','View reconciliation','Read reconciliation records.','reconciliation','view',false,true),
('payment-report.view','View payment report','Read payment reporting.','reporting','view',false,true),
('fiscal-report.view','View fiscal report','Read fiscal reporting.','reporting','view',false,true),
('sales-invoice-report.view','View Sales Invoice report','Read Sales Invoice reports.','reporting','view',false,true),
('statutory-discount-report.view','View statutory discount report','Read statutory discount reports.','reporting','view',false,true),
('revenue-report.view','View revenue report','Read revenue reports.','reporting','view',false,true),
('variance-report.view','View variance report','Read variance reports.','reporting','view',false,true),
('reports.view','View reports','Read reporting surfaces.','reporting','view',false,true),
('reports.export','Export reports','Export governed reports.','reporting','export',true,true),
('dashboard.view','View dashboard','Read dashboards.','reporting','view',false,true),
('executive-summary.view','View executive summary','Read executive summaries.','reporting','view',false,true),
('site-performance.view','View Site performance','Read Site performance.','reporting','view',false,true),
('site-group-performance.view','View Site Group performance','Read Site Group performance.','reporting','view',false,true),
('revenue-summary.view','View revenue summary','Read revenue summaries.','reporting','view',false,true),
('payment-summary.view','View payment summary','Read payment summaries.','reporting','view',false,true),
('fiscal-summary.view','View fiscal summary','Read fiscal summaries.','reporting','view',false,true),
('statutory-discount-summary.view','View statutory summary','Read statutory summaries.','reporting','view',false,true),
('exception-trend.view','View exception trends','Read exception trends.','reporting','view',false,true),
('audit-report.view','View audit report','Read audit reports.','audit','view',true,true),
('compliance-report.view','View compliance report','Read compliance reports.','reporting','view',true,true),
('policy-import.submit','Submit policy import','Submit a policy import.','policy','submit',true,true),
('policy-import.review','Review policy import','Review a policy import.','policy','review',true,true),
('policy-import.approve','Approve policy import','Approve a policy import.','policy','approve',true,true),
('policy-import.manage','Manage policy import','Manage policy imports.','policy','manage',true,true),
('operator-console.policy-import-review.submit','Submit console policy import','Submit an Operator Console policy import.','policy','submit',true,true),
('operator-console.policy-import-review.view-own','View own console policy import','Read own Operator Console policy import.','policy','view',true,true),
('operator-console.policy-import-review.review','Review console policy import','Review Operator Console policy import.','policy','review',true,true),
('operator-console.policy-import-review.manage','Manage console policy import','Manage Operator Console policy imports.','policy','manage',true,true),
('operator-console.policy-import-review.approve.legal','Approve legal policy import','Legal policy-import approval.','policy','approve',true,true),
('operator-console.policy-import-review.approve.ops','Approve operations policy import','Operations policy-import approval.','policy','approve',true,true),
('operator-console.policy-import-review.approve.qa','Approve QA policy import','QA policy-import approval.','policy','approve',true,true),
('operator-console.policy-import-review.approve.db','Approve DB policy import','Database policy-import approval.','policy','approve',true,true),
('statutory-discount-policy.view','View statutory policy','Read statutory policy.','policy','view',true,true),
('statutory-discount-policy.manage','Manage statutory policy','Manage statutory policy.','policy','manage',true,true),
('evidence-rule-policy.view','View evidence rule policy','Read evidence-rule policy.','policy','view',true,true),
('evidence-rule-policy.manage','Manage evidence rule policy','Manage evidence-rule policy.','policy','manage',true,true),
('fiscal-reporting.ej.read','Read Electronic Journal','Read Electronic Journal fiscal records.','fiscal-reporting','read',true,true),
('fiscal-reporting.ej.export','Export Electronic Journal','Export Electronic Journal fiscal records.','fiscal-reporting','export',true,true),
('fiscal-reporting.x.read','Read X reports','Read X report records.','fiscal-reporting','read',true,true),
('fiscal-reporting.x.generate','Generate X report','Generate a non-closing X report.','fiscal-reporting','generate',true,true),
('fiscal-reporting.z.read','Read Z reports','Read Z report records.','fiscal-reporting','read',true,true),
('fiscal-reporting.z.generate','Generate Z report','Generate a closing Z report.','fiscal-reporting','generate',true,true);

INSERT INTO identity.permissions (permission_id,permission_code,permission_name,permission_description,
    permission_domain,permission_action,permission_status,is_sensitive,requires_audit,
    created_by_service_identity_id,updated_by_service_identity_id)
SELECT pg_temp.exitpass_wave3_uuid('wave3:permission:'||permission_code),permission_code,
    permission_name,permission_description,permission_domain,permission_action,'ACTIVE',
    is_sensitive,requires_audit,'1f2ffdfb-c4a9-5a00-a656-9f3a132b1978',
    '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
FROM wave3_permissions
ON CONFLICT ON CONSTRAINT uq_permissions__permission_code DO UPDATE SET
    permission_name=EXCLUDED.permission_name, permission_description=EXCLUDED.permission_description,
    permission_domain=EXCLUDED.permission_domain, permission_action=EXCLUDED.permission_action,
    permission_status='ACTIVE', is_sensitive=EXCLUDED.is_sensitive,
    requires_audit=EXCLUDED.requires_audit, updated_at=now(),
    row_version=identity.permissions.row_version+1
WHERE (identity.permissions.permission_name,identity.permissions.permission_description,
       identity.permissions.permission_domain,identity.permissions.permission_action,
       identity.permissions.permission_status,identity.permissions.is_sensitive,
       identity.permissions.requires_audit)
  IS DISTINCT FROM
      (EXCLUDED.permission_name,EXCLUDED.permission_description,
       EXCLUDED.permission_domain,EXCLUDED.permission_action,
       'ACTIVE'::identity.permission_status_enum,EXCLUDED.is_sensitive,
       EXCLUDED.requires_audit);

CREATE TEMP TABLE wave3_compatibility(role_code varchar(64),user_type identity.user_type_enum,
    PRIMARY KEY(role_code,user_type)) ON COMMIT DROP;
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

CREATE TEMP TABLE wave3_role_permissions(role_code varchar(64),permission_code varchar(96),
    PRIMARY KEY(role_code,permission_code)) ON COMMIT DROP;
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
('OPERATIONS_SUPERVISOR','statutory-discounts.review.queue.read'),('OPERATIONS_SUPERVISOR','statutory-discounts.review.detail.read'),
('OPERATIONS_SUPERVISOR','statutory-discounts.evidence.review.view'),('OPERATIONS_SUPERVISOR','statutory-discounts.decision.review'),
('OPERATIONS_SUPERVISOR','statutory-discounts.decision.approve'),('OPERATIONS_SUPERVISOR','statutory-discounts.decision.reject'),
('OPERATIONS_SUPERVISOR','statutory-discounts.policy.resolve'),('OPERATIONS_SUPERVISOR','fiscal-issuance.status.read'),
('OPERATIONS_SUPERVISOR','operator-workflow-audit.view'),('OPERATIONS_SUPERVISOR','projection-health.view'),
('OPERATIONS_SUPERVISOR','ops.vendor-session-projection-health.view'),('OPERATIONS_SUPERVISOR','vendor-acknowledgments.view'),
('SITE_OPERATOR','sessions.resolve'),('SITE_OPERATOR','gate.consume_authorization'),
('SITE_OPERATOR','gate.record_event'),('SITE_OPERATOR','operations.manual_gate'),
('SITE_OPERATOR','apt.access'),('SITE_OPERATOR','cashier-shifts.operate'),
('SITE_OPERATOR','cash-custody.operate'),('SITE_OPERATOR','terminal-cash.receive'),
('SUPPORT_AGENT','sessions.resolve'),('SUPPORT_AGENT','tariffs.quote'),('SUPPORT_AGENT','ticket.lookup'),
('SUPPORT_AGENT','projection-health.view'),('SUPPORT_AGENT','ops.vendor-session-projection-health.view'),
('SUPPORT_AGENT','operator-console.vendor-projection-health.view'),('SUPPORT_AGENT','vendor-acknowledgments.view'),
('SUPPORT_AGENT','audit.read'),
('FINANCE_RECONCILIATION_ANALYST','reconciliation.view'),('FINANCE_RECONCILIATION_ANALYST','payment-report.view'),
('FINANCE_RECONCILIATION_ANALYST','fiscal-report.view'),('FINANCE_RECONCILIATION_ANALYST','sales-invoice-report.view'),
('FINANCE_RECONCILIATION_ANALYST','statutory-discount-report.view'),('FINANCE_RECONCILIATION_ANALYST','revenue-report.view'),
('FINANCE_RECONCILIATION_ANALYST','variance-report.view'),('FINANCE_RECONCILIATION_ANALYST','reports.view'),
('FINANCE_RECONCILIATION_ANALYST','reports.export'),('FINANCE_RECONCILIATION_ANALYST','fiscal-reporting.ej.read'),
('FINANCE_RECONCILIATION_ANALYST','fiscal-reporting.ej.export'),('FINANCE_RECONCILIATION_ANALYST','fiscal-reporting.x.read'),
('FINANCE_RECONCILIATION_ANALYST','fiscal-reporting.x.generate'),('FINANCE_RECONCILIATION_ANALYST','fiscal-reporting.z.read'),
('COMPLIANCE_REVIEWER','statutory-discounts.review.queue.read'),('COMPLIANCE_REVIEWER','statutory-discounts.review.detail.read'),
('COMPLIANCE_REVIEWER','statutory-discounts.evidence.review.view'),('COMPLIANCE_REVIEWER','statutory-discounts.audit.read'),
('COMPLIANCE_REVIEWER','audit.read'),('COMPLIANCE_REVIEWER','evidence.read_restricted'),
('COMPLIANCE_REVIEWER','compliance-report.view'),
('COMPLIANCE_POLICY_ADMINISTRATOR','statutory-discounts.audit.read'),
('COMPLIANCE_POLICY_ADMINISTRATOR','fiscal-issuance.void.audit.read'),('COMPLIANCE_POLICY_ADMINISTRATOR','fiscal-view-audit.read'),
('COMPLIANCE_POLICY_ADMINISTRATOR','audit-report.view'),('COMPLIANCE_POLICY_ADMINISTRATOR','compliance-report.view'),
('COMPLIANCE_POLICY_ADMINISTRATOR','policy-import.submit'),('COMPLIANCE_POLICY_ADMINISTRATOR','policy-import.review'),
('COMPLIANCE_POLICY_ADMINISTRATOR','policy-import.approve'),('COMPLIANCE_POLICY_ADMINISTRATOR','policy-import.manage'),
('COMPLIANCE_POLICY_ADMINISTRATOR','operator-console.policy-import-review.submit'),
('COMPLIANCE_POLICY_ADMINISTRATOR','operator-console.policy-import-review.view-own'),
('COMPLIANCE_POLICY_ADMINISTRATOR','operator-console.policy-import-review.review'),
('COMPLIANCE_POLICY_ADMINISTRATOR','operator-console.policy-import-review.manage'),
('COMPLIANCE_POLICY_ADMINISTRATOR','operator-console.policy-import-review.approve.legal'),
('COMPLIANCE_POLICY_ADMINISTRATOR','operator-console.policy-import-review.approve.ops'),
('COMPLIANCE_POLICY_ADMINISTRATOR','operator-console.policy-import-review.approve.qa'),
('COMPLIANCE_POLICY_ADMINISTRATOR','operator-console.policy-import-review.approve.db'),
('COMPLIANCE_POLICY_ADMINISTRATOR','statutory-discount-policy.view'),('COMPLIANCE_POLICY_ADMINISTRATOR','statutory-discount-policy.manage'),
('COMPLIANCE_POLICY_ADMINISTRATOR','evidence-rule-policy.view'),('COMPLIANCE_POLICY_ADMINISTRATOR','evidence-rule-policy.manage'),
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
('SECURITY_REVIEWER','user.view'),('SECURITY_REVIEWER','rbac.view'),('SECURITY_REVIEWER','role.view'),
('SECURITY_REVIEWER','permission.view'),('SECURITY_REVIEWER','assignment.view'),
('SECURITY_REVIEWER','access-audit.view'),('SECURITY_REVIEWER','human-authentication.session.admin.view');

-- SYSTEM_ADMIN is explicit break-glass and receives every active non-UAT permission.
INSERT INTO wave3_role_permissions
SELECT 'SYSTEM_ADMIN',p.permission_code FROM identity.permissions p
WHERE p.permission_status='ACTIVE' AND p.permission_code<>'uat-fixture.manage'
ON CONFLICT DO NOTHING;

UPDATE identity.role_permissions rp SET binding_status='RETIRED', effective_to=now(),
    revocation_reason_code='WAVE3_CANONICAL_PERMISSION_REVIEW', updated_at=now(),
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

INSERT INTO identity.role_permissions(role_permission_id,role_id,permission_id,binding_status,
    binding_reason_code,assigned_by_service_identity_id,effective_from,
    created_by_service_identity_id,updated_by_service_identity_id)
SELECT pg_temp.exitpass_wave3_uuid('wave3:role-permission:'||m.role_code||':'||m.permission_code),
    r.role_id,p.permission_id,'ACTIVE','WAVE3_CANONICAL_PERMISSION_REVIEW',
    '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978','2020-01-01T00:00:00Z',
    '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978','1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
FROM wave3_role_permissions m JOIN identity.roles r ON r.role_code=m.role_code
JOIN identity.permissions p ON p.permission_code=m.permission_code
WHERE NOT EXISTS (
    SELECT 1 FROM identity.role_permissions active
    WHERE active.role_id=r.role_id AND active.permission_id=p.permission_id
      AND active.binding_status='ACTIVE')
ON CONFLICT (role_permission_id) DO UPDATE SET binding_status='ACTIVE',effective_to=NULL,
    revoked_at=NULL,revocation_reason_code=NULL,updated_at=now(),
    row_version=identity.role_permissions.row_version+1
WHERE identity.role_permissions.binding_status<>'ACTIVE'
   OR identity.role_permissions.effective_to IS NOT NULL
   OR identity.role_permissions.revoked_at IS NOT NULL
   OR identity.role_permissions.revocation_reason_code IS NOT NULL;

COMMIT;
