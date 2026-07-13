CREATE TABLE IF NOT EXISTS discounts.statutory_entitlement_fingerprints (
    statutory_entitlement_fingerprint_id uuid DEFAULT gen_random_uuid() NOT NULL,
    statutory_discount_validation_id uuid NOT NULL,
    entitlement_type discounts.statutory_entitlement_type_enum NOT NULL,
    fingerprint_hash char(64) NOT NULL,
    fingerprint_algorithm varchar(64) NOT NULL,
    fingerprint_algorithm_version varchar(32) NOT NULL,
    salt_reference varchar(256) NOT NULL,
    source_metadata_level varchar(64) NOT NULL,
    duplicate_detection_scope varchar(64) NOT NULL,
    matched_existing_fingerprint_id uuid,
    fingerprint_status discounts.entitlement_fingerprint_status_enum NOT NULL,
    generated_at timestamptz NOT NULL,
    generated_by_service_identity_id uuid NOT NULL,
    retention_policy_code varchar(64) NOT NULL,
    purged_at timestamptz,
    correlation_id uuid,
    created_at timestamptz DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamptz DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT pk_statutory_entitlement_fingerprints PRIMARY KEY (statutory_entitlement_fingerprint_id),
    CONSTRAINT fk_statutory_entitlement_fingerprints__validation_id FOREIGN KEY (statutory_discount_validation_id)
        REFERENCES discounts.statutory_discount_validations(statutory_discount_validation_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_statutory_entitlement_fingerprints__matched_existing_id FOREIGN KEY (matched_existing_fingerprint_id)
        REFERENCES discounts.statutory_entitlement_fingerprints(statutory_entitlement_fingerprint_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_stat_ent_fps__generated_svc_identity FOREIGN KEY (generated_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_statutory_entitlement_fingerprints__created_by_user_id FOREIGN KEY (created_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_stat_ent_fps__created_svc_identity FOREIGN KEY (created_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_statutory_entitlement_fingerprints__updated_by_user_id FOREIGN KEY (updated_by_user_id)
        REFERENCES identity.users(user_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_stat_ent_fps__updated_svc_identity FOREIGN KEY (updated_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT ck_statutory_entitlement_fingerprints__row_version_positive CHECK (row_version > 0)
);;

