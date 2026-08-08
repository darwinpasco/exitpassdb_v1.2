-- ExitPass v1.3 APT human operational permission reference data.
-- I-021A freezes these permissions as distinct, Site-scoped human capabilities.

BEGIN;

CREATE TEMP TABLE i021b_apt_permissions (
    permission_id uuid PRIMARY KEY,
    permission_code varchar(96) UNIQUE NOT NULL,
    permission_name varchar(128) NOT NULL,
    permission_description text NOT NULL,
    permission_domain varchar(64) NOT NULL,
    permission_action varchar(64) NOT NULL,
    is_sensitive boolean NOT NULL
) ON COMMIT DROP;

INSERT INTO i021b_apt_permissions VALUES
('6bcab461-3595-145e-5807-c8449228cdb6', 'apt.access', 'Access Assisted Payment Terminal', 'Enter and use the APT after human authentication, device binding, and Site authorization. Does not authorize shift, custody, or cash receipt operations.', 'apt', 'access', false),
('307d7772-6b84-d76f-0e7e-980fab9a1e5c', 'cashier-shifts.operate', 'Operate own cashier shift', 'Open, resume, and close the authenticated cashier''s own shift. Does not authorize another cashier''s shift, custody, cash receipt, or supervisor handover.', 'cashier-shifts', 'operate', true),
('cd0e161b-3010-f559-1486-fbcd65dc9434', 'cash-custody.operate', 'Operate own cash custody', 'Open, resume, and close the authenticated cashier''s own cash-custody session. Does not authorize another cashier''s custody, cash receipt, or supervisor handover.', 'cash-custody', 'operate', true),
('93989b4d-6be8-27c8-8053-1cc128cbcc20', 'terminal-cash.receive', 'Receive terminal cash', 'Supply the human-permission dimension for physical cash acceptance immediately before CASH_RECEIVED. This permission is necessary but never sufficient by itself.', 'terminal-cash', 'receive', true);

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
    permission_id,
    permission_code,
    permission_name,
    permission_description,
    permission_domain,
    permission_action,
    'ACTIVE',
    is_sensitive,
    true
FROM i021b_apt_permissions
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

CREATE TEMP TABLE i021b_site_operator_bindings (
    role_permission_id uuid PRIMARY KEY,
    permission_code varchar(96) UNIQUE NOT NULL
) ON COMMIT DROP;

INSERT INTO i021b_site_operator_bindings VALUES
('fd1580da-c069-5250-e49f-697d767af8a1', 'apt.access'),
('45b48318-f583-7fd1-d048-d1e753f4057a', 'cashier-shifts.operate'),
('06730455-c02f-4f7f-d89a-c822f76ab2f0', 'cash-custody.operate'),
('e1504522-9e04-571d-d507-9b9441012ee4', 'terminal-cash.receive');

INSERT INTO identity.role_permissions (
    role_permission_id,
    role_id,
    permission_id,
    binding_status,
    binding_reason_code,
    assigned_by_service_identity_id,
    effective_from,
    created_by_service_identity_id,
    updated_by_service_identity_id
)
SELECT
    binding.role_permission_id,
    role.role_id,
    permission.permission_id,
    'ACTIVE',
    'I021B_APT_OPERATIONAL_BASELINE',
    '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978',
    now(),
    '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978',
    '1f2ffdfb-c4a9-5a00-a656-9f3a132b1978'
FROM i021b_site_operator_bindings binding
JOIN identity.permissions permission ON permission.permission_code = binding.permission_code
JOIN identity.roles role ON role.role_code = 'SITE_OPERATOR'
WHERE NOT EXISTS (
    SELECT 1
    FROM identity.role_permissions existing
    WHERE existing.role_id = role.role_id
      AND existing.permission_id = permission.permission_id
      AND existing.binding_status = 'ACTIVE'
);

COMMIT;
