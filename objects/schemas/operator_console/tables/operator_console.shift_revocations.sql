CREATE TABLE IF NOT EXISTS operator_console.shift_revocations (
    shift_revocation_id uuid DEFAULT gen_random_uuid() NOT NULL,
    operator_shift_id uuid NOT NULL,
    revocation_status operator_console.shift_revocation_status_enum NOT NULL,
    reason_code varchar(64) NOT NULL,
    reason_note text,
    requested_by_user_id uuid NOT NULL,
    approved_by_user_id uuid,
    revoked_operator_user_id uuid NOT NULL,
    site_id uuid NOT NULL,
    requested_at timestamptz NOT NULL,
    approved_at timestamptz,
    effective_at timestamptz,
    correlation_id uuid,
    created_at timestamptz DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamptz DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT pk_shift_revocations PRIMARY KEY (shift_revocation_id),
    CONSTRAINT fk_shift_revocations__operator_shift_id FOREIGN KEY (operator_shift_id)
        REFERENCES operator_console.operator_shifts(operator_shift_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_revocations__requested_by_user_id FOREIGN KEY (requested_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_revocations__approved_by_user_id FOREIGN KEY (approved_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_revocations__revoked_operator_user_id FOREIGN KEY (revoked_operator_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_revocations__site_id FOREIGN KEY (site_id)
        REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_revocations__created_by_user_id FOREIGN KEY (created_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_revocations__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_revocations__updated_by_user_id FOREIGN KEY (updated_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_revocations__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT ck_shift_revocations__row_version_positive CHECK (row_version > 0)
);;

