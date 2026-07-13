CREATE TABLE IF NOT EXISTS operator_console.shift_takeovers (
    shift_takeover_id uuid DEFAULT gen_random_uuid() NOT NULL,
    operator_shift_id uuid NOT NULL,
    original_operator_user_id uuid NOT NULL,
    takeover_operator_user_id uuid NOT NULL,
    takeover_status operator_console.shift_takeover_status_enum NOT NULL,
    reason_code varchar(64) NOT NULL,
    reason_note text,
    requested_by_user_id uuid NOT NULL,
    approved_by_user_id uuid,
    site_id uuid NOT NULL,
    requested_at timestamptz NOT NULL,
    approved_at timestamptz,
    active_from timestamptz,
    active_to timestamptz,
    ended_at timestamptz,
    correlation_id uuid,
    created_at timestamptz DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamptz DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT pk_shift_takeovers PRIMARY KEY (shift_takeover_id),
    CONSTRAINT fk_shift_takeovers__operator_shift_id FOREIGN KEY (operator_shift_id)
        REFERENCES operator_console.operator_shifts(operator_shift_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_takeovers__original_operator_user_id FOREIGN KEY (original_operator_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_takeovers__takeover_operator_user_id FOREIGN KEY (takeover_operator_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_takeovers__requested_by_user_id FOREIGN KEY (requested_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_takeovers__approved_by_user_id FOREIGN KEY (approved_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_takeovers__site_id FOREIGN KEY (site_id)
        REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_takeovers__created_by_user_id FOREIGN KEY (created_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_takeovers__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_takeovers__updated_by_user_id FOREIGN KEY (updated_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_shift_takeovers__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT ck_shift_takeovers__different_users CHECK (original_operator_user_id <> takeover_operator_user_id),
    CONSTRAINT ck_shift_takeovers__active_window CHECK (active_to IS NULL OR active_from IS NULL OR active_to > active_from),
    CONSTRAINT ck_shift_takeovers__row_version_positive CHECK (row_version > 0)
);;

