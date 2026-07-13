CREATE TABLE IF NOT EXISTS operator_console.operator_shifts (
    operator_shift_id uuid DEFAULT gen_random_uuid() NOT NULL,
    hr_provider_code varchar(64) NOT NULL,
    external_shift_id_hash char(64) NOT NULL,
    external_shift_id_masked varchar(64),
    hr_identity_mapping_id uuid NOT NULL,
    operator_user_id uuid NOT NULL,
    site_group_id uuid NOT NULL,
    site_id uuid NOT NULL,
    scheduled_start_at timestamptz NOT NULL,
    scheduled_end_at timestamptz NOT NULL,
    source_imported_at timestamptz NOT NULL,
    import_status_code varchar(64) NOT NULL,
    source_system_code varchar(64) NOT NULL,
    source_status_code varchar(96),
    source_status_description text,
    operational_status operator_console.operator_shift_operational_status_enum NOT NULL,
    active_from timestamptz,
    active_to timestamptz,
    revoked_at timestamptz,
    revoked_by_user_id uuid,
    revocation_reason_code varchar(64),
    current_takeover_id uuid,
    correlation_id uuid,
    created_at timestamptz DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamptz DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT pk_operator_shifts PRIMARY KEY (operator_shift_id),
    CONSTRAINT fk_operator_shifts__hr_identity_mapping_id FOREIGN KEY (hr_identity_mapping_id)
        REFERENCES operator_console.hr_identity_mappings(hr_identity_mapping_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_shifts__operator_user_id FOREIGN KEY (operator_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_shifts__site_group_id FOREIGN KEY (site_group_id)
        REFERENCES sites.site_groups(site_group_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_shifts__site_id FOREIGN KEY (site_id)
        REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_shifts__revoked_by_user_id FOREIGN KEY (revoked_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_shifts__created_by_user_id FOREIGN KEY (created_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_shifts__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_shifts__updated_by_user_id FOREIGN KEY (updated_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_shifts__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT ck_operator_shifts__scheduled_window CHECK (scheduled_end_at > scheduled_start_at),
    CONSTRAINT ck_operator_shifts__active_window CHECK (active_to IS NULL OR active_from IS NULL OR active_to > active_from),
    CONSTRAINT ck_operator_shifts__row_version_positive CHECK (row_version > 0)
);;

