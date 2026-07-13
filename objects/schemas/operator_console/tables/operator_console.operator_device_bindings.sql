CREATE TABLE IF NOT EXISTS operator_console.operator_device_bindings (
    operator_device_binding_id uuid DEFAULT gen_random_uuid() NOT NULL,
    device_binding_code varchar(64) NOT NULL,
    device_name varchar(128) NOT NULL,
    site_group_id uuid NOT NULL,
    site_id uuid NOT NULL,
    service_identity_id uuid,
    browser_key_thumbprint char(64),
    browser_public_key_ref varchar(256),
    mtls_certificate_thumbprint char(64),
    mtls_certificate_subject varchar(256),
    mtls_certificate_expires_at timestamptz,
    device_status operator_console.operator_device_binding_status_enum NOT NULL,
    trust_level operator_console.operator_device_trust_level_enum NOT NULL,
    binding_source varchar(64) NOT NULL,
    last_seen_at timestamptz,
    revoked_at timestamptz,
    revocation_reason_code varchar(64),
    lost_reported_at timestamptz,
    correlation_id uuid,
    created_at timestamptz DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamptz DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT pk_operator_device_bindings PRIMARY KEY (operator_device_binding_id),
    CONSTRAINT fk_operator_device_bindings__site_group_id FOREIGN KEY (site_group_id)
        REFERENCES sites.site_groups(site_group_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_device_bindings__site_id FOREIGN KEY (site_id)
        REFERENCES sites.sites(site_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_device_bindings__service_identity_id FOREIGN KEY (service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_device_bindings__created_by_user_id FOREIGN KEY (created_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_device_bindings__created_by_service_identity_id FOREIGN KEY (created_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_device_bindings__updated_by_user_id FOREIGN KEY (updated_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_operator_device_bindings__updated_by_service_identity_id FOREIGN KEY (updated_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT ck_operator_device_bindings__has_trust_material CHECK (
        browser_key_thumbprint IS NOT NULL
        OR mtls_certificate_thumbprint IS NOT NULL
        OR service_identity_id IS NOT NULL
    ),
    CONSTRAINT ck_operator_device_bindings__row_version_positive CHECK (row_version > 0)
);;

