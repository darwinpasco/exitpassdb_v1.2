\set ON_ERROR_STOP on
-- Read-only Wave 3 inventory. This script contains no mutation statement.
WITH affected AS (
  SELECT u.user_id, u.username, u.user_type::text AS user_type, u.user_status::text AS user_status,
         ur.user_role_id, r.role_id, r.role_code, r.role_name,
         r.role_provenance::text AS role_provenance, ur.assignment_status::text AS assignment_status,
         CASE
           WHEN r.role_code IN ('FINANCE_RECONCILIATION','UAT_FINANCE_RECONCILIATION_ANALYST')
                THEN 'FINANCE_RECONCILIATION_ANALYST'
           WHEN r.role_code IN ('OPERATOR_SUPPORT_STAFF','UAT_OPERATOR_SUPPORT_STAFF')
                AND u.user_type='SITE_OPERATOR' THEN 'SITE_OPERATOR'
           WHEN r.role_code IN ('OPERATOR_SUPPORT_STAFF','UAT_OPERATOR_SUPPORT_STAFF')
                AND u.user_type='SUPPORT_USER' THEN 'SUPPORT_AGENT'
           WHEN r.role_code LIKE 'UAT\_%' ESCAPE '\' THEN substring(r.role_code from 5)
           ELSE NULL
         END AS proposed_canonical_role_code
  FROM identity.users u
  JOIN identity.user_roles ur ON ur.user_id=u.user_id
  JOIN identity.roles r ON r.role_id=ur.role_id
  WHERE ur.assignment_status='ACTIVE'
    AND (r.role_provenance IN ('UAT_TEST_ROLE','HISTORICAL_LEGACY_ROLE')
         OR r.role_code IN ('FINANCE_RECONCILIATION','OPERATOR_SUPPORT_STAFF'))
)
SELECT affected.*,
       CASE
         WHEN proposed_canonical_role_code IS NULL THEN NULL
         WHEN username='uat-operations-supervisor'
              AND role_code='UAT_OPERATIONS_SUPERVISOR'
              AND user_type='SITE_OPERATOR' THEN 'OPERATIONS_USER'
         WHEN role_code='UAT_EXECUTIVE_MANAGEMENT' AND user_type<>'OTHER' THEN 'OTHER'
         ELSE user_type
       END AS proposed_user_type,
       CASE
         WHEN proposed_canonical_role_code IS NULL THEN 'PRODUCT_DECISION_REQUIRED'
         WHEN username='uat-operations-supervisor'
              AND role_code='UAT_OPERATIONS_SUPERVISOR'
              AND user_type='SITE_OPERATOR'
           THEN 'DETERMINISTIC_UAT_FIXTURE_USER_TYPE_CORRECTION'
         WHEN EXISTS (
           SELECT 1
           FROM identity.roles target
           JOIN identity.role_user_type_compatibility compatible ON compatible.role_id=target.role_id
           WHERE target.role_code=affected.proposed_canonical_role_code
             AND target.role_provenance='CANONICAL_ROLE'
             AND compatible.user_type::text=affected.user_type)
           THEN 'DETERMINISTIC'
         ELSE 'PRODUCT_DECISION_REQUIRED'
       END AS migration_disposition
FROM affected
ORDER BY username, role_code, user_role_id;
