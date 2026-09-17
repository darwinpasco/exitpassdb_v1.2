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

-- These granular v1.3 permission definitions remain available for application
-- policy composition. The approved eight-role catalog binds APT human authority
-- only through apt.cashier.operate on APT_CASHIER_OPERATOR.

COMMIT;
