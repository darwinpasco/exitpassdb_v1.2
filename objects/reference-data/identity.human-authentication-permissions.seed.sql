BEGIN;

CREATE OR REPLACE FUNCTION pg_temp.exitpass_i019_uuid(input text)
RETURNS uuid
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT (
        substr(md5(input), 1, 8) || '-' ||
        substr(md5(input), 9, 4) || '-' ||
        substr(md5(input), 13, 4) || '-' ||
        substr(md5(input), 17, 4) || '-' ||
        substr(md5(input), 21, 12)
    )::uuid
$$;

CREATE TEMP TABLE i019_permissions (
    permission_code varchar(96) PRIMARY KEY,
    permission_name varchar(128) NOT NULL,
    permission_description text NOT NULL,
    permission_domain varchar(64) NOT NULL,
    permission_action varchar(64) NOT NULL
) ON COMMIT DROP;

INSERT INTO i019_permissions VALUES
('human-authentication.session.self.view', 'View own human sessions', 'Read privacy-safe current and concurrent human session status for the authenticated user.', 'human-authentication', 'view-self-session'),
('human-authentication.session.self.revoke', 'Revoke own human sessions', 'Revoke another session belonging to the authenticated user.', 'human-authentication', 'revoke-self-session'),
('human-authentication.session.admin.view', 'View governed human sessions', 'Read privacy-safe human session administration inventory.', 'human-authentication', 'view-sessions'),
('human-authentication.session.admin.revoke', 'Revoke governed human sessions', 'Revoke another user human session under governed authority.', 'human-authentication', 'revoke-session'),
('human-authentication.credential.reset', 'Reset local human credential', 'Issue a governed local credential activation or reset challenge without selecting or reading the password.', 'human-authentication', 'reset-credential'),
('human-authentication.mfa.status.view', 'View MFA status', 'Read privacy-safe MFA requirement and authenticator lifecycle status without secret material.', 'human-authentication', 'view-mfa-status'),
('human-authentication.mfa.reset', 'Reset MFA authenticator', 'Invalidate a governed MFA authenticator and require new enrollment without reading its protected secret.', 'human-authentication', 'reset-mfa'),
('human-authentication.mfa.remove', 'Remove MFA authenticator', 'Remove a governed MFA authenticator subject to privileged-account safety policy.', 'human-authentication', 'remove-mfa'),
('identity.role-assignment.manage', 'Manage role assignments', 'Create, revoke, and review governed human user-role assignments.', 'identity', 'manage-role-assignment'),
('identity.scope-assignment.manage', 'Manage role scope assignments', 'Create, revoke, and review governed Site, Site Group, and approved explicit GLOBAL role scopes.', 'identity', 'manage-scope-assignment'),
('identity.privileged-access.decide', 'Decide privileged access', 'Record an authorized independent decision for a privileged role or scope request.', 'identity', 'decide-privileged-access'),
('identity.access-review.manage', 'Manage access reviews', 'Record governed role and scope access-review outcomes.', 'identity', 'manage-access-review');

INSERT INTO identity.permissions (
    permission_id,
    permission_code,
    permission_name,
    permission_description,
    permission_domain,
    permission_action,
    permission_status,
    is_sensitive,
    requires_audit
)
SELECT
    pg_temp.exitpass_i019_uuid('i019:permission:' || permission_code),
    permission_code,
    permission_name,
    permission_description,
    permission_domain,
    permission_action,
    'ACTIVE',
    true,
    true
FROM i019_permissions
ON CONFLICT ON CONSTRAINT uq_permissions__permission_code DO UPDATE
SET permission_name = EXCLUDED.permission_name,
    permission_description = EXCLUDED.permission_description,
    permission_domain = EXCLUDED.permission_domain,
    permission_action = EXCLUDED.permission_action,
    permission_status = EXCLUDED.permission_status,
    is_sensitive = EXCLUDED.is_sensitive,
    requires_audit = EXCLUDED.requires_audit,
    updated_at = now(),
    row_version = identity.permissions.row_version + 1;

COMMIT;;
