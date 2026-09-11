\set ON_ERROR_STOP on
\if :{?APPLY_AUTHORIZED}
\else
  \set APPLY_AUTHORIZED false
\endif

-- REVIEW-ONLY artifact. It is inert unless psql is explicitly invoked with:
--   -v APPLY_AUTHORIZED=true
-- Persistent execution requires separate product-owner and database-change authorization.
\if :APPLY_AUTHORIZED
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

DO $$
BEGIN
  IF (SELECT count(*) FROM sites.real_carpark_catalog_site_groups
      WHERE catalog_code = 'PROFESSIONAL_PARKING_REAL_CARPARK_V1') <> 39 THEN
    RAISE EXCEPTION 'Reconciliation refused: canonical Site Group membership is not exactly 39.';
  END IF;

  IF (SELECT count(*) FROM identity.users WHERE username = 'DarwinPasco25') <> 1 THEN
    RAISE EXCEPTION 'Reconciliation refused: DarwinPasco25 does not resolve to exactly one identity.';
  END IF;

  IF (SELECT count(*)
      FROM identity.users u
      JOIN identity.user_roles ur ON ur.user_id = u.user_id
      JOIN identity.roles r ON r.role_id = ur.role_id
      WHERE u.username = 'DarwinPasco25'
        AND ur.assignment_status = 'ACTIVE'
        AND ur.effective_from <= now()
        AND (ur.effective_to IS NULL OR ur.effective_to > now())
        AND r.role_code = 'SYSTEM_RBAC_ADMINISTRATOR') <> 1 THEN
    RAISE EXCEPTION 'Reconciliation refused: current administrator role assignment is not uniquely resolvable; coordinate with Wave 3.';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM identity.users u
    JOIN identity.user_roles ur ON ur.user_id = u.user_id
    JOIN identity.user_role_scope_grants g ON g.user_role_id = ur.user_role_id
    WHERE u.username = 'DarwinPasco25'
      AND g.grant_status = 'ACTIVE'
      AND g.effective_from <= now()
      AND (g.effective_to IS NULL OR g.effective_to > now())
      AND (g.scope_type = 'GLOBAL'
        OR (g.scope_type = 'SITE_GROUP' AND NOT EXISTS (
          SELECT 1 FROM sites.real_carpark_catalog_site_groups c
          WHERE c.site_group_id = g.site_group_id
            AND c.catalog_code = 'PROFESSIONAL_PARKING_REAL_CARPARK_V1')))
  ) THEN
    RAISE EXCEPTION 'Reconciliation refused: administrator has a GLOBAL or non-canonical active Site Group grant.';
  END IF;
END $$;

WITH target AS (
  SELECT u.user_id, ur.user_role_id
  FROM identity.users u
  JOIN identity.user_roles ur ON ur.user_id = u.user_id
  JOIN identity.roles r ON r.role_id = ur.role_id
  WHERE u.username = 'DarwinPasco25'
    AND ur.assignment_status = 'ACTIVE'
    AND ur.effective_from <= now()
    AND (ur.effective_to IS NULL OR ur.effective_to > now())
    AND r.role_code = 'SYSTEM_RBAC_ADMINISTRATOR'
), missing AS (
  SELECT target.user_id, target.user_role_id, catalog.site_group_id
  FROM target
  CROSS JOIN sites.real_carpark_catalog_site_groups catalog
  WHERE catalog.catalog_code = 'PROFESSIONAL_PARKING_REAL_CARPARK_V1'
    AND NOT EXISTS (
      SELECT 1
      FROM identity.user_roles existing_role
      JOIN identity.user_role_scope_grants existing ON existing.user_role_id = existing_role.user_role_id
      WHERE existing_role.user_id = target.user_id
        AND existing.scope_type = 'SITE_GROUP'
        AND existing.site_group_id = catalog.site_group_id
        AND existing.grant_status = 'ACTIVE'
        AND existing.effective_from <= now()
        AND (existing.effective_to IS NULL OR existing.effective_to > now()))
), inserted AS (
  INSERT INTO identity.user_role_scope_grants (
    user_role_scope_grant_id, user_role_id, scope_type, site_group_id,
    grant_status, grant_reason_code, effective_from, granted_at,
    granted_by_user_id, created_by_user_id, updated_by_user_id
  )
  SELECT gen_random_uuid(), missing.user_role_id, 'SITE_GROUP', missing.site_group_id,
         'ACTIVE', 'APPROVED_REAL_CARPARK_DELEGATION_RECONCILIATION', now(), now(),
         missing.user_id, missing.user_id, missing.user_id
  FROM missing
  RETURNING user_role_scope_grant_id, granted_by_user_id
), correlation AS (
  SELECT gen_random_uuid() AS correlation_id
)
INSERT INTO audit.audit_events (
  audit_event_id, event_type, event_category, event_result, event_reason_code,
  target_entity_type, target_entity_id, source_schema, source_service_name,
  source_channel, actor_user_id, summary, occurred_at, recorded_at,
  correlation_id, created_at
)
SELECT gen_random_uuid(), 'SITE_GROUP_SCOPE_GRANTED', 'SECURITY_RELEVANT', 'SUCCESS',
       'APPROVED_REAL_CARPARK_DELEGATION_RECONCILIATION', 'UserRoleScopeGrant',
       inserted.user_role_scope_grant_id, 'identity', 'governed-database-reconciliation',
       'CONTROLLED_MIGRATION', inserted.granted_by_user_id,
       'An approved real Professional Parking Site Group delegation grant was reconciled.',
       now(), now(), correlation.correlation_id, now()
FROM inserted CROSS JOIN correlation;

DO $$
BEGIN
  IF (SELECT count(DISTINCT g.site_group_id)
      FROM identity.users u
      JOIN identity.user_roles ur ON ur.user_id = u.user_id
      JOIN identity.user_role_scope_grants g ON g.user_role_id = ur.user_role_id
      JOIN sites.real_carpark_catalog_site_groups c ON c.site_group_id = g.site_group_id
      WHERE u.username = 'DarwinPasco25'
        AND g.scope_type = 'SITE_GROUP'
        AND g.grant_status = 'ACTIVE'
        AND g.effective_from <= now()
        AND (g.effective_to IS NULL OR g.effective_to > now())
        AND c.catalog_code = 'PROFESSIONAL_PARKING_REAL_CARPARK_V1') <> 39 THEN
    RAISE EXCEPTION 'Reconciliation failed: administrator does not have exactly 39 distinct canonical Site Group grants.';
  END IF;
END $$;

COMMIT;
\else
  \echo 'REVIEW ONLY: no changes applied. Separate authorization and -v APPLY_AUTHORIZED=true are required.'
\endif
