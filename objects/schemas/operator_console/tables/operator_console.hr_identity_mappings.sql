CREATE TABLE IF NOT EXISTS operator_console.hr_identity_mappings (
    hr_identity_mapping_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    hr_provider_code varchar(64) NOT NULL,
    external_person_id_hash char(64) NOT NULL,
    external_person_id_masked varchar(64),
    external_employee_number_hash char(64),
    external_employee_number_masked varchar(64),
    mapping_status operator_console.hr_identity_mapping_status_enum NOT NULL,
    effective_from timestamptz NOT NULL,
    effective_to timestamptz,
    revoked_at timestamptz,
    revoked_by_user_id uuid,
    revoked_by_service_identity_id uuid,
    revocation_reason_code varchar(64),
    correlation_id uuid,
    created_at timestamptz DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamptz DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT pk_hr_identity_mappings PRIMARY KEY (hr_identity_mapping_id),
    CONSTRAINT fk_hr_identity_mappings__user_id FOREIGN KEY (user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_hr_identity_mappings__revoked_by_user_id FOREIGN KEY (revoked_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_hr_identity_mappings__revoked_by_service_identity_id FOREIGN KEY (revoked_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_hr_identity_mappings__created_by_user_id FOREIGN KEY (created_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_hr_identity_mappings__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_hr_identity_mappings__updated_by_user_id FOREIGN KEY (updated_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_hr_identity_mappings__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT ck_hr_identity_mappings__effective_window CHECK (effective_to IS NULL OR effective_to > effective_from),
    CONSTRAINT ck_hr_identity_mappings__row_version_positive CHECK (row_version > 0)
);;

