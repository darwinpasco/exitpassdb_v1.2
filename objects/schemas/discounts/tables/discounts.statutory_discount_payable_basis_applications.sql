CREATE TABLE IF NOT EXISTS discounts.statutory_discount_payable_basis_applications (
    statutory_discount_payable_basis_application_id uuid DEFAULT gen_random_uuid() NOT NULL,
    statutory_discount_validation_id uuid NOT NULL,
    parking_session_id uuid NOT NULL,
    original_tariff_snapshot_id uuid NOT NULL,
    applied_tariff_snapshot_id uuid,
    application_status discounts.statutory_discount_payable_application_status_enum NOT NULL,
    application_channel discounts.statutory_discount_payable_application_channel_enum NOT NULL,
    gross_amount_minor_units bigint NOT NULL,
    vat_amount_minor_units bigint NOT NULL,
    vat_exclusive_amount_minor_units bigint NOT NULL,
    statutory_discount_amount_minor_units bigint NOT NULL,
    final_payable_amount_minor_units bigint NOT NULL,
    currency_code char(3) NOT NULL,
    computation_basis_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    rounding_mode varchar(64) DEFAULT 'HALF_AWAY_FROM_ZERO' NOT NULL,
    applied_at timestamptz,
    applied_by_user_id uuid,
    applied_by_service_identity_id uuid,
    idempotency_key varchar(128),
    correlation_id uuid NOT NULL,
    created_at timestamptz DEFAULT now() NOT NULL,
    created_by_user_id uuid,
    created_by_service_identity_id uuid,
    updated_at timestamptz DEFAULT now() NOT NULL,
    updated_by_user_id uuid,
    updated_by_service_identity_id uuid,
    row_version bigint DEFAULT 1 NOT NULL,
    CONSTRAINT pk_statutory_discount_payable_basis_applications
        PRIMARY KEY (statutory_discount_payable_basis_application_id),
    CONSTRAINT fk_sd_pba__validation
        FOREIGN KEY (statutory_discount_validation_id)
        REFERENCES discounts.statutory_discount_validations(statutory_discount_validation_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_sd_pba__parking_session
        FOREIGN KEY (parking_session_id)
        REFERENCES core.parking_sessions(parking_session_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_sd_pba__original_tariff_snapshot
        FOREIGN KEY (original_tariff_snapshot_id)
        REFERENCES core.tariff_snapshots(tariff_snapshot_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_sd_pba__applied_tariff_snapshot
        FOREIGN KEY (applied_tariff_snapshot_id)
        REFERENCES core.tariff_snapshots(tariff_snapshot_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_sd_pba__applied_by_user
        FOREIGN KEY (applied_by_user_id)
        REFERENCES identity.users(user_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_sd_pba__applied_by_service_identity
        FOREIGN KEY (applied_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_sd_pba__created_by_user
        FOREIGN KEY (created_by_user_id)
        REFERENCES identity.users(user_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_sd_pba__created_by_service_identity
        FOREIGN KEY (created_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_sd_pba__updated_by_user
        FOREIGN KEY (updated_by_user_id)
        REFERENCES identity.users(user_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT fk_sd_pba__updated_by_service_identity
        FOREIGN KEY (updated_by_service_identity_id)
        REFERENCES identity.service_identities(service_identity_id)
        DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT ck_sd_pba__gross_non_negative
        CHECK (gross_amount_minor_units >= 0),
    CONSTRAINT ck_sd_pba__vat_non_negative
        CHECK (vat_amount_minor_units >= 0),
    CONSTRAINT ck_sd_pba__vat_exclusive_non_negative
        CHECK (vat_exclusive_amount_minor_units >= 0),
    CONSTRAINT ck_sd_pba__discount_non_negative
        CHECK (statutory_discount_amount_minor_units >= 0),
    CONSTRAINT ck_sd_pba__final_non_negative
        CHECK (final_payable_amount_minor_units >= 0),
    CONSTRAINT ck_sd_pba__gross_components
        CHECK (vat_exclusive_amount_minor_units + vat_amount_minor_units = gross_amount_minor_units),
    CONSTRAINT ck_sd_pba__final_not_greater_than_gross
        CHECK (final_payable_amount_minor_units <= gross_amount_minor_units),
    CONSTRAINT ck_sd_pba__discount_not_greater_than_vat_exclusive
        CHECK (statutory_discount_amount_minor_units <= vat_exclusive_amount_minor_units),
    CONSTRAINT ck_sd_pba__currency_code
        CHECK (currency_code = upper(currency_code) AND currency_code ~ '^[A-Z]{3}$'),
    CONSTRAINT ck_sd_pba__applied_fields
        CHECK (
            application_status <> 'APPLIED'
            OR (applied_tariff_snapshot_id IS NOT NULL AND applied_at IS NOT NULL)
        ),
    CONSTRAINT ck_sd_pba__distinct_snapshots
        CHECK (applied_tariff_snapshot_id IS NULL OR applied_tariff_snapshot_id <> original_tariff_snapshot_id),
    CONSTRAINT ck_sd_pba__row_version_positive
        CHECK (row_version > 0)
);;

