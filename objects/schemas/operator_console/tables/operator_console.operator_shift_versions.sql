CREATE TABLE IF NOT EXISTS operator_console.operator_shift_versions (
    operator_shift_version_id uuid DEFAULT gen_random_uuid() NOT NULL,
    operator_shift_id uuid NOT NULL,
    hr_provider_code varchar(64) NOT NULL,
    external_shift_id_hash char(64) NOT NULL,
    source_payload_hash char(64),
    source_payload_ref varchar(256),
    import_status_code varchar(64) NOT NULL,
    source_system_code varchar(64) NOT NULL,
    source_status_code varchar(96),
    source_status_description text,
    scheduled_start_at timestamptz NOT NULL,
    scheduled_end_at timestamptz NOT NULL,
    site_id uuid,
    operator_user_id uuid,
    imported_at timestamptz NOT NULL,
    imported_by_service_identity_id uuid NOT NULL,
    correlation_id uuid,
    CONSTRAINT pk_operator_shift_versions PRIMARY KEY (operator_shift_version_id),
    CONSTRAINT fk_operator_shift_versions__operator_shift_id FOREIGN KEY (operator_shift_id)
        REFERENCES operator_console.operator_shifts(operator_shift_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_shift_versions__site_id FOREIGN KEY (site_id)
        REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_shift_versions__operator_user_id FOREIGN KEY (operator_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_shift_versions__imported_by_service_identity_id FOREIGN KEY (imported_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT ck_operator_shift_versions__scheduled_window CHECK (scheduled_end_at > scheduled_start_at)
);;

