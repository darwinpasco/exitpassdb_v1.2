\set ON_ERROR_STOP on
\if :{?APPLY_AUTHORIZED}
\else
  \set APPLY_AUTHORIZED false
\endif

-- REVIEW-ONLY artifact. Persistent execution requires separate authorization and:
--   psql -v APPLY_AUTHORIZED=true -f Reconcile-DarwinPasco25-Canonical-System-Rbac-Administrator.sql
\if :APPLY_AUTHORIZED
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT pg_advisory_xact_lock(hashtext('exitpass.wave3.darwinpasco25.canonical-rbac'));

DO $$
BEGIN
  IF (SELECT count(*) FROM identity.users WHERE username='DarwinPasco25') <> 1 THEN
    RAISE EXCEPTION 'DarwinPasco25 must resolve to exactly one identity.';
  END IF;
  IF (SELECT count(*) FROM identity.roles WHERE role_code='SYSTEM_RBAC_ADMINISTRATOR'
      AND role_provenance='CANONICAL_ROLE' AND role_status='ACTIVE') <> 1 THEN
    RAISE EXCEPTION 'Canonical SYSTEM_RBAC_ADMINISTRATOR is unavailable.';
  END IF;
  IF (SELECT count(*) FROM identity.roles WHERE role_code='UAT_SYSTEM_RBAC_ADMINISTRATOR'
      AND role_provenance='UAT_TEST_ROLE') <> 1 THEN
    RAISE EXCEPTION 'UAT predecessor role is not uniquely identifiable.';
  END IF;
  IF EXISTS (
    SELECT 1 FROM identity.users u JOIN identity.user_roles ur ON ur.user_id=u.user_id
    JOIN identity.roles r ON r.role_id=ur.role_id
    WHERE u.username='DarwinPasco25' AND ur.assignment_status='ACTIVE'
      AND r.role_code='UAT_SYSTEM_RBAC_ADMINISTRATOR'
      AND EXISTS (SELECT 1 FROM identity.user_role_scope_grants g
                  WHERE g.user_role_id=ur.user_role_id AND g.grant_status='ACTIVE'
                    AND NOT (g.scope_type='SITE_GROUP' AND EXISTS (
                      SELECT 1 FROM sites.site_groups sg WHERE sg.site_group_id=g.site_group_id
                        AND sg.site_group_code='PITX'))
                    AND NOT (g.scope_type='SITE' AND EXISTS (
                      SELECT 1 FROM sites.sites s JOIN sites.site_groups sg ON sg.site_group_id=s.site_group_id
                      WHERE s.site_id=g.site_id AND sg.site_group_code='PITX')))) THEN
    RAISE EXCEPTION 'UAT predecessor has active scope outside PITX; review required.';
  END IF;
END $$;

CREATE TEMP TABLE wave3_darwin_state ON COMMIT DROP AS
SELECT u.user_id,
       (SELECT ur.user_role_id FROM identity.user_roles ur JOIN identity.roles r ON r.role_id=ur.role_id
        WHERE ur.user_id=u.user_id AND r.role_code='UAT_SYSTEM_RBAC_ADMINISTRATOR'
        ORDER BY (ur.assignment_status='ACTIVE') DESC, ur.assigned_at DESC LIMIT 1) AS old_assignment_id,
       (SELECT r.role_id FROM identity.roles r WHERE r.role_code='SYSTEM_RBAC_ADMINISTRATOR'
        AND r.role_provenance='CANONICAL_ROLE') AS canonical_role_id,
       '23a939d2-f28f-5dcc-b17e-4cb7af97f286'::uuid AS correlation_id
FROM identity.users u WHERE u.username='DarwinPasco25';

INSERT INTO identity.user_roles(user_role_id,user_id,role_id,assignment_status,assignment_reason_code,
  assigned_by_user_id,effective_from,created_by_user_id,updated_by_user_id)
SELECT gen_random_uuid(),s.user_id,s.canonical_role_id,'ACTIVE','WAVE3_CANONICAL_RBAC_MIGRATION',
       s.user_id,now(),s.user_id,s.user_id
FROM wave3_darwin_state s
WHERE NOT EXISTS (SELECT 1 FROM identity.user_roles ur WHERE ur.user_id=s.user_id
  AND ur.role_id=s.canonical_role_id AND ur.assignment_status='ACTIVE');

INSERT INTO identity.user_role_scope_grants(user_role_scope_grant_id,user_role_id,scope_type,site_id,site_group_id,
  grant_status,grant_reason_code,effective_from,granted_by_user_id,created_by_user_id,updated_by_user_id)
SELECT gen_random_uuid(),new_ur.user_role_id,g.scope_type,g.site_id,g.site_group_id,'ACTIVE',
       'WAVE3_PRESERVE_PITX_SCOPE',now(),s.user_id,s.user_id,s.user_id
FROM wave3_darwin_state s
JOIN identity.user_roles old_ur ON old_ur.user_role_id=s.old_assignment_id
JOIN identity.user_role_scope_grants g ON g.user_role_id=old_ur.user_role_id AND g.grant_status='ACTIVE'
JOIN identity.user_roles new_ur ON new_ur.user_id=s.user_id AND new_ur.role_id=s.canonical_role_id
  AND new_ur.assignment_status='ACTIVE'
WHERE NOT EXISTS (SELECT 1 FROM identity.user_role_scope_grants existing
  WHERE existing.user_role_id=new_ur.user_role_id AND existing.grant_status='ACTIVE'
    AND existing.scope_type=g.scope_type
    AND existing.site_id IS NOT DISTINCT FROM g.site_id
    AND existing.site_group_id IS NOT DISTINCT FROM g.site_group_id);

UPDATE identity.user_roles ur SET assignment_status='REVOKED',revoked_at=now(),
  revoked_by_user_id=s.user_id,revocation_reason_code='WAVE3_CANONICAL_RBAC_MIGRATION',
  updated_at=now(),updated_by_user_id=s.user_id,row_version=ur.row_version+1
FROM wave3_darwin_state s
WHERE ur.user_role_id=s.old_assignment_id AND ur.assignment_status='ACTIVE'
  AND EXISTS (SELECT 1 FROM identity.user_roles active_new
              WHERE active_new.user_id=s.user_id AND active_new.role_id=s.canonical_role_id
                AND active_new.assignment_status='ACTIVE');

UPDATE identity.users u SET authorization_epoch=authorization_epoch+1,updated_at=now(),
  updated_by_user_id=s.user_id,row_version=u.row_version+1
FROM wave3_darwin_state s WHERE u.user_id=s.user_id
  AND NOT EXISTS (SELECT 1 FROM audit.audit_events a WHERE a.correlation_id=s.correlation_id);

UPDATE identity.human_sessions hs SET session_status='REVOKED',revoked_at=now(),
  revoked_by_user_id=s.user_id,revocation_reason_code='WAVE3_CANONICAL_RBAC_MIGRATION',
  updated_at=now(),updated_by_user_id=s.user_id,row_version=hs.row_version+1
FROM wave3_darwin_state s WHERE hs.user_id=s.user_id AND hs.session_status='ACTIVE';

INSERT INTO audit.audit_events(audit_event_id,event_type,event_category,event_result,event_reason_code,
 target_entity_type,target_entity_id,source_schema,source_service_name,source_channel,actor_user_id,
 summary,occurred_at,recorded_at,correlation_id,created_at)
SELECT gen_random_uuid(),'ROLE_MIGRATED','SECURITY_RELEVANT','SUCCESS','WAVE3_CANONICAL_RBAC_MIGRATION',
 'IdentityUser',s.user_id,'identity','governed-database-reconciliation','CONTROLLED_MIGRATION',s.user_id,
 'Canonical SYSTEM_RBAC_ADMINISTRATOR activated before the UAT predecessor was revoked; PITX scope preserved and sessions invalidated.',
 now(),now(),s.correlation_id,now() FROM wave3_darwin_state s
WHERE NOT EXISTS (SELECT 1 FROM audit.audit_events existing WHERE existing.correlation_id=s.correlation_id);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM identity.users u JOIN identity.user_roles ur ON ur.user_id=u.user_id
    JOIN identity.roles r ON r.role_id=ur.role_id WHERE u.username='DarwinPasco25'
    AND ur.assignment_status='ACTIVE' AND r.role_code='SYSTEM_RBAC_ADMINISTRATOR'
    AND r.role_provenance='CANONICAL_ROLE') THEN
    RAISE EXCEPTION 'Canonical administrator continuity verification failed.';
  END IF;
END $$;
COMMIT;
\else
  \echo 'REVIEW ONLY: DarwinPasco25 canonical role migration was NOT applied.'
\endif
