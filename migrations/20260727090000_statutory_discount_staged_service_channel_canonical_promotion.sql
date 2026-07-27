-- ExitPass v1.3 statutory-discount staged/service-channel canonical DB promotion.
-- Additive migration safe for canonical-only environments and environments that already applied the app-local statutory patch chain.

ALTER TABLE discounts.statutory_discount_validations
    ADD COLUMN IF NOT EXISTS id_document_type varchar(64) NULL,
    ADD COLUMN IF NOT EXISTS issuing_authority varchar(128) NULL,
    ADD COLUMN IF NOT EXISTS id_expiry_date date NULL,
    ADD COLUMN IF NOT EXISTS masked_id_reference varchar(64) NULL,
    ADD COLUMN IF NOT EXISTS requester_attestation boolean NULL,
    ADD COLUMN IF NOT EXISTS attestation_notes varchar(512) NULL;

ALTER TABLE discounts.statutory_discount_validations
    DROP CONSTRAINT IF EXISTS ck_stat_disc_validations__id_doc_type_supported,
    DROP CONSTRAINT IF EXISTS ck_stat_disc_validations__masked_id_reference_safe;
ALTER TABLE discounts.statutory_discount_validations
    ADD CONSTRAINT ck_stat_disc_validations__id_doc_type_supported CHECK (id_document_type IS NULL OR id_document_type IN ('SENIOR_CITIZEN_ID', 'PWD_ID', 'OTHER_SUPPORTING_DOCUMENT')),
    ADD CONSTRAINT ck_stat_disc_validations__masked_id_reference_safe CHECK (masked_id_reference IS NULL OR masked_id_reference LIKE '%*%' OR masked_id_reference ~* '^sha256:[0-9a-f]{64}$' OR masked_id_reference !~ '[0-9]{6,}');
CREATE INDEX IF NOT EXISTS ix_stat_disc_validations__decision_v2_fact_presence
    ON discounts.statutory_discount_validations (statutory_discount_validation_id)
    WHERE id_document_type IS NOT NULL OR masked_id_reference IS NOT NULL OR requester_attestation IS NOT NULL;

CREATE TABLE IF NOT EXISTS discounts.statutory_discount_decision_commands (
    statutory_discount_decision_command_id uuid NOT NULL DEFAULT gen_random_uuid(), request_reference uuid NOT NULL, parking_session_id uuid NOT NULL,
    source_channel varchar(64) NOT NULL, entitlement_type varchar(64) NOT NULL, business_identity varchar(256) NULL,
    idempotency_scope varchar(256) NOT NULL, idempotency_key varchar(128) NOT NULL, semantic_request_hash varchar(80) NOT NULL,
    semantic_hash_source_version varchar(64) NOT NULL, statutory_discount_validation_id uuid NULL, payable_basis_application_id uuid NULL,
    original_tariff_snapshot_id uuid NULL, applied_tariff_snapshot_id uuid NULL, decision_status varchar(64) NOT NULL,
    command_status varchar(64) NOT NULL DEFAULT 'PROCESSING', decision_result_status varchar(64) NOT NULL DEFAULT 'NOT_DECIDED',
    result_classification varchar(64) NOT NULL, retryable boolean NOT NULL DEFAULT false, recovery_classification varchar(80) NOT NULL DEFAULT 'NONE',
    policy_resolution_basis varchar(80) NULL, applied_policy_reference_id uuid NULL, fallback_policy_reference_id uuid NULL,
    local_ordinance_applied boolean NOT NULL DEFAULT false, gross_amount_minor_units bigint NULL, vat_exclusive_amount_minor_units bigint NULL,
    vat_amount_minor_units bigint NULL, statutory_discount_amount_minor_units bigint NULL, net_payable_amount_minor_units bigint NULL,
    currency_code char(3) NULL, evidence_required boolean NOT NULL DEFAULT false, evidence_recorded boolean NOT NULL DEFAULT false,
    reason_code varchar(128) NULL, error_code varchar(128) NULL, original_correlation_id uuid NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(), processing_started_at timestamptz NULL, decided_at timestamptz NULL,
    applied_at timestamptz NULL, completed_at timestamptz NULL, failed_at timestamptz NULL, updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT pk_statutory_discount_decision_commands PRIMARY KEY (statutory_discount_decision_command_id)
);
ALTER TABLE discounts.statutory_discount_decision_commands
    ADD COLUMN IF NOT EXISTS business_identity varchar(256) NULL,
    ADD COLUMN IF NOT EXISTS command_status varchar(64) NOT NULL DEFAULT 'PROCESSING',
    ADD COLUMN IF NOT EXISTS decision_result_status varchar(64) NOT NULL DEFAULT 'NOT_DECIDED',
    ADD COLUMN IF NOT EXISTS retryable boolean NOT NULL DEFAULT false,
    ADD COLUMN IF NOT EXISTS recovery_classification varchar(80) NOT NULL DEFAULT 'NONE',
    ADD COLUMN IF NOT EXISTS vat_exclusive_amount_minor_units bigint NULL,
    ADD COLUMN IF NOT EXISTS vat_amount_minor_units bigint NULL,
    ADD COLUMN IF NOT EXISTS processing_started_at timestamptz NULL,
    ADD COLUMN IF NOT EXISTS failed_at timestamptz NULL;
UPDATE discounts.statutory_discount_decision_commands SET business_identity = idempotency_scope WHERE business_identity IS NULL AND idempotency_scope LIKE 'statutory-discount-decision:%';
ALTER TABLE discounts.statutory_discount_decision_commands
    DROP CONSTRAINT IF EXISTS ck_statutory_discount_decision_commands__source_channel,
    DROP CONSTRAINT IF EXISTS ck_statutory_discount_decision_commands__entitlement_type,
    DROP CONSTRAINT IF EXISTS ck_statutory_discount_decision_commands__hash,
    DROP CONSTRAINT IF EXISTS ck_statutory_discount_decision_commands__semantic_version,
    DROP CONSTRAINT IF EXISTS ck_statutory_discount_decision_commands__decision_status,
    DROP CONSTRAINT IF EXISTS ck_statutory_discount_decision_commands__command_status,
    DROP CONSTRAINT IF EXISTS ck_statutory_discount_decision_commands__decision_result_status,
    DROP CONSTRAINT IF EXISTS ck_statutory_discount_decision_commands__result_classification,
    DROP CONSTRAINT IF EXISTS ck_stat_disc_decision_cmds__recovery,
    DROP CONSTRAINT IF EXISTS ck_statutory_discount_decision_commands__recovery_classification,
    DROP CONSTRAINT IF EXISTS ck_statutory_discount_decision_commands__recovery_classificatio;
ALTER TABLE discounts.statutory_discount_decision_commands
    ADD CONSTRAINT ck_statutory_discount_decision_commands__source_channel CHECK (source_channel IN ('OPERATOR_CONSOLE','WEBPAY','ASSISTED_PAYMENT_TERMINAL')),
    ADD CONSTRAINT ck_statutory_discount_decision_commands__entitlement_type CHECK (entitlement_type IN ('SENIOR_CITIZEN','PWD')),
    ADD CONSTRAINT ck_statutory_discount_decision_commands__hash CHECK (semantic_request_hash ~ '^sha256:[0-9a-f]{64}$'),
    ADD CONSTRAINT ck_statutory_discount_decision_commands__semantic_version CHECK (semantic_hash_source_version IN ('statutory-discount-decision:sha256:v1','statutory-discount-decision:sha256:v2')),
    ADD CONSTRAINT ck_statutory_discount_decision_commands__decision_status CHECK (decision_status IN ('PROCESSING','REQUESTED','PENDING_OPERATOR_REVIEW','APPROVED','REJECTED','FAILED','EXPIRED','CANCELLED','APPLIED_PAYABLE_BASIS')),
    ADD CONSTRAINT ck_statutory_discount_decision_commands__command_status CHECK (command_status IN ('RECEIVED','PROCESSING','AWAITING_REVIEW','COMPLETED','FAILED_RETRYABLE','FAILED_NON_RETRYABLE')),
    ADD CONSTRAINT ck_statutory_discount_decision_commands__decision_result_status CHECK (decision_result_status IN ('APPROVED','REJECTED','NOT_DECIDED')),
    ADD CONSTRAINT ck_statutory_discount_decision_commands__result_classification CHECK (result_classification IN ('ACCEPTED','IDEMPOTENT_REPLAY','AWAITING_REVIEW')),
    ADD CONSTRAINT ck_stat_disc_decision_cmds__recovery CHECK (recovery_classification IN ('NONE','AWAITING_REVIEW','READ_CANONICAL_RESULT','RETRY_ORIGINAL_IDEMPOTENCY_KEY','WAIT_THEN_RETRY_ORIGINAL_IDEMPOTENCY_KEY','CORRECT_REQUEST_REQUIRED','NOT_RECOVERABLE'));

CREATE UNIQUE INDEX IF NOT EXISTS ux_statutory_discount_decision_commands__idempotency ON discounts.statutory_discount_decision_commands (idempotency_scope, idempotency_key);
CREATE UNIQUE INDEX IF NOT EXISTS ux_statutory_discount_decision_commands__business_identity ON discounts.statutory_discount_decision_commands (parking_session_id, entitlement_type);
CREATE UNIQUE INDEX IF NOT EXISTS ux_statutory_discount_decision_commands__request_reference ON discounts.statutory_discount_decision_commands (request_reference);
CREATE UNIQUE INDEX IF NOT EXISTS ux_statutory_discount_decision_commands__business_identity_text ON discounts.statutory_discount_decision_commands (business_identity) WHERE business_identity IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_statutory_discount_decision_commands__parking_session ON discounts.statutory_discount_decision_commands (parking_session_id);
CREATE INDEX IF NOT EXISTS ix_statutory_discount_decision_commands__validation ON discounts.statutory_discount_decision_commands (statutory_discount_validation_id);
CREATE INDEX IF NOT EXISTS ix_statutory_discount_decision_commands__correlation ON discounts.statutory_discount_decision_commands (original_correlation_id);
CREATE INDEX IF NOT EXISTS ix_statutory_discount_decision_commands__command_status ON discounts.statutory_discount_decision_commands (command_status);

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_statutory_discount_decision_commands__parking_session') THEN ALTER TABLE discounts.statutory_discount_decision_commands ADD CONSTRAINT fk_statutory_discount_decision_commands__parking_session FOREIGN KEY (parking_session_id) REFERENCES core.parking_sessions(parking_session_id); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_statutory_discount_decision_commands__validation') THEN ALTER TABLE discounts.statutory_discount_decision_commands ADD CONSTRAINT fk_statutory_discount_decision_commands__validation FOREIGN KEY (statutory_discount_validation_id) REFERENCES discounts.statutory_discount_validations(statutory_discount_validation_id); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_statutory_discount_decision_commands__payable_basis_application') THEN ALTER TABLE discounts.statutory_discount_decision_commands ADD CONSTRAINT fk_statutory_discount_decision_commands__payable_basis_application FOREIGN KEY (payable_basis_application_id) REFERENCES discounts.statutory_discount_payable_basis_applications(statutory_discount_payable_basis_application_id); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_statutory_discount_decision_commands__original_tariff_snapshot') THEN ALTER TABLE discounts.statutory_discount_decision_commands ADD CONSTRAINT fk_statutory_discount_decision_commands__original_tariff_snapshot FOREIGN KEY (original_tariff_snapshot_id) REFERENCES core.tariff_snapshots(tariff_snapshot_id); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_statutory_discount_decision_commands__applied_tariff_snapshot') THEN ALTER TABLE discounts.statutory_discount_decision_commands ADD CONSTRAINT fk_statutory_discount_decision_commands__applied_tariff_snapshot FOREIGN KEY (applied_tariff_snapshot_id) REFERENCES core.tariff_snapshots(tariff_snapshot_id); END IF;
END $$;

CREATE TABLE IF NOT EXISTS discounts.statutory_discount_payable_basis_application_commands (
    statutory_discount_payable_basis_application_command_id uuid NOT NULL DEFAULT gen_random_uuid(), request_reference uuid NOT NULL,
    statutory_discount_decision_command_id uuid NOT NULL, parking_session_id uuid NOT NULL, site_id uuid NULL, entitlement_type varchar(64) NOT NULL,
    business_identity varchar(256) NOT NULL, idempotency_scope varchar(256) NOT NULL, idempotency_key varchar(128) NOT NULL,
    semantic_request_hash varchar(80) NOT NULL, semantic_hash_source_version varchar(80) NOT NULL, command_status varchar(64) NOT NULL,
    result_classification varchar(64) NOT NULL, retryable boolean NOT NULL DEFAULT false, recovery_classification varchar(80) NOT NULL DEFAULT 'NONE',
    safe_error_code varchar(128) NULL, statutory_discount_validation_id uuid NULL, statutory_discount_payable_basis_application_id uuid NULL,
    original_tariff_snapshot_id uuid NULL, target_tariff_snapshot_id uuid NULL, applied_tariff_snapshot_id uuid NULL, applied_policy_reference_id uuid NULL,
    policy_resolution_basis varchar(80) NULL, approved_discount_amount_minor_units bigint NOT NULL, approved_vat_exclusive_amount_minor_units bigint NULL,
    approved_vat_amount_minor_units bigint NULL, approved_final_payable_amount_minor_units bigint NOT NULL, currency_code char(3) NOT NULL,
    source_channel varchar(64) NOT NULL, original_correlation_id uuid NOT NULL, created_at timestamptz NOT NULL DEFAULT now(),
    processing_started_at timestamptz NULL, applied_at timestamptz NULL, completed_at timestamptz NULL, failed_at timestamptz NULL,
    updated_at timestamptz NOT NULL DEFAULT now(), CONSTRAINT pk_statutory_discount_payable_basis_application_commands PRIMARY KEY (statutory_discount_payable_basis_application_command_id)
);
ALTER TABLE discounts.statutory_discount_payable_basis_application_commands
    DROP CONSTRAINT IF EXISTS ck_stat_discount_pba_commands__source_channel,
    DROP CONSTRAINT IF EXISTS ck_stat_discount_pba_commands__entitlement_type,
    DROP CONSTRAINT IF EXISTS ck_stat_discount_pba_commands__hash,
    DROP CONSTRAINT IF EXISTS ck_stat_discount_pba_commands__semantic_version,
    DROP CONSTRAINT IF EXISTS ck_stat_discount_pba_commands__command_status,
    DROP CONSTRAINT IF EXISTS ck_stat_discount_pba_commands__result_classification,
    DROP CONSTRAINT IF EXISTS ck_stat_discount_pba_commands__recovery_classification,
    DROP CONSTRAINT IF EXISTS ck_stat_discount_pba_commands__amounts_non_negative;
ALTER TABLE discounts.statutory_discount_payable_basis_application_commands
    ADD CONSTRAINT ck_stat_discount_pba_commands__source_channel CHECK (source_channel IN ('OPERATOR_CONSOLE','WEBPAY','ASSISTED_PAYMENT_TERMINAL')),
    ADD CONSTRAINT ck_stat_discount_pba_commands__entitlement_type CHECK (entitlement_type IN ('SENIOR_CITIZEN','PWD')),
    ADD CONSTRAINT ck_stat_discount_pba_commands__hash CHECK (semantic_request_hash ~ '^sha256:[0-9a-f]{64}$'),
    ADD CONSTRAINT ck_stat_discount_pba_commands__semantic_version CHECK (semantic_hash_source_version = 'statutory-discount-payable-basis-application:sha256:v1'),
    ADD CONSTRAINT ck_stat_discount_pba_commands__command_status CHECK (command_status IN ('RECEIVED','PROCESSING','APPLIED','FAILED_RETRYABLE','FAILED_NON_RETRYABLE')),
    ADD CONSTRAINT ck_stat_discount_pba_commands__result_classification CHECK (result_classification IN ('APPLIED','IDEMPOTENT_REPLAY','SEMANTIC_CONFLICT','DECISION_NOT_APPROVED','DECISION_NOT_FOUND','IN_PROGRESS','RETRYABLE_FAILURE','NON_RETRYABLE_FAILURE')),
    ADD CONSTRAINT ck_stat_discount_pba_commands__recovery_classification CHECK (recovery_classification IN ('NONE','AWAITING_REVIEW','READ_CANONICAL_RESULT','RETRY_ORIGINAL_IDEMPOTENCY_KEY','WAIT_THEN_RETRY_ORIGINAL_IDEMPOTENCY_KEY','CORRECT_REQUEST_REQUIRED','NOT_RECOVERABLE')),
    ADD CONSTRAINT ck_stat_discount_pba_commands__amounts_non_negative CHECK (approved_discount_amount_minor_units >= 0 AND approved_final_payable_amount_minor_units >= 0 AND (approved_vat_exclusive_amount_minor_units IS NULL OR approved_vat_exclusive_amount_minor_units >= 0) AND (approved_vat_amount_minor_units IS NULL OR approved_vat_amount_minor_units >= 0));
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_stat_discount_pba_commands__decision_command') THEN ALTER TABLE discounts.statutory_discount_payable_basis_application_commands ADD CONSTRAINT fk_stat_discount_pba_commands__decision_command FOREIGN KEY (statutory_discount_decision_command_id) REFERENCES discounts.statutory_discount_decision_commands(statutory_discount_decision_command_id); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_stat_discount_pba_commands__parking_session') THEN ALTER TABLE discounts.statutory_discount_payable_basis_application_commands ADD CONSTRAINT fk_stat_discount_pba_commands__parking_session FOREIGN KEY (parking_session_id) REFERENCES core.parking_sessions(parking_session_id); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_stat_discount_pba_commands__site') THEN ALTER TABLE discounts.statutory_discount_payable_basis_application_commands ADD CONSTRAINT fk_stat_discount_pba_commands__site FOREIGN KEY (site_id) REFERENCES sites.sites(site_id); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_stat_discount_pba_commands__validation') THEN ALTER TABLE discounts.statutory_discount_payable_basis_application_commands ADD CONSTRAINT fk_stat_discount_pba_commands__validation FOREIGN KEY (statutory_discount_validation_id) REFERENCES discounts.statutory_discount_validations(statutory_discount_validation_id); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_stat_discount_pba_commands__payable_basis_application') THEN ALTER TABLE discounts.statutory_discount_payable_basis_application_commands ADD CONSTRAINT fk_stat_discount_pba_commands__payable_basis_application FOREIGN KEY (statutory_discount_payable_basis_application_id) REFERENCES discounts.statutory_discount_payable_basis_applications(statutory_discount_payable_basis_application_id); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_stat_discount_pba_commands__original_tariff_snapshot') THEN ALTER TABLE discounts.statutory_discount_payable_basis_application_commands ADD CONSTRAINT fk_stat_discount_pba_commands__original_tariff_snapshot FOREIGN KEY (original_tariff_snapshot_id) REFERENCES core.tariff_snapshots(tariff_snapshot_id); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_stat_discount_pba_commands__target_tariff_snapshot') THEN ALTER TABLE discounts.statutory_discount_payable_basis_application_commands ADD CONSTRAINT fk_stat_discount_pba_commands__target_tariff_snapshot FOREIGN KEY (target_tariff_snapshot_id) REFERENCES core.tariff_snapshots(tariff_snapshot_id); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_stat_discount_pba_commands__applied_tariff_snapshot') THEN ALTER TABLE discounts.statutory_discount_payable_basis_application_commands ADD CONSTRAINT fk_stat_discount_pba_commands__applied_tariff_snapshot FOREIGN KEY (applied_tariff_snapshot_id) REFERENCES core.tariff_snapshots(tariff_snapshot_id); END IF;
END $$;
CREATE UNIQUE INDEX IF NOT EXISTS ux_stat_discount_pba_commands__business_identity ON discounts.statutory_discount_payable_basis_application_commands (business_identity);
CREATE UNIQUE INDEX IF NOT EXISTS ux_stat_discount_pba_commands__decision_command ON discounts.statutory_discount_payable_basis_application_commands (statutory_discount_decision_command_id);
CREATE UNIQUE INDEX IF NOT EXISTS ux_stat_discount_pba_commands__idempotency ON discounts.statutory_discount_payable_basis_application_commands (idempotency_scope, idempotency_key);
CREATE UNIQUE INDEX IF NOT EXISTS ux_stat_discount_pba_commands__request_reference ON discounts.statutory_discount_payable_basis_application_commands (request_reference);
CREATE INDEX IF NOT EXISTS ix_stat_discount_pba_commands__parking_session ON discounts.statutory_discount_payable_basis_application_commands (parking_session_id);
CREATE INDEX IF NOT EXISTS ix_stat_discount_pba_commands__validation ON discounts.statutory_discount_payable_basis_application_commands (statutory_discount_validation_id);
CREATE INDEX IF NOT EXISTS ix_stat_discount_pba_commands__correlation ON discounts.statutory_discount_payable_basis_application_commands (original_correlation_id);

CREATE TABLE IF NOT EXISTS operator_console.statutory_discount_service_channel_reviews (
    statutory_discount_decision_command_id uuid NOT NULL, request_reference uuid NOT NULL, parking_session_id uuid NOT NULL,
    source_channel varchar(64) NOT NULL, site_id uuid NULL, site_group_id uuid NULL, ticket_reference varchar(160) NULL, plate_number varchar(32) NULL,
    entitlement_type varchar(64) NOT NULL, id_document_type varchar(64) NULL, issuing_authority varchar(160) NULL, expiry_date date NULL,
    masked_id_reference varchar(128) NULL, evidence_references jsonb NOT NULL DEFAULT '[]'::jsonb, requester_attestation boolean NOT NULL DEFAULT false,
    attestation_notes varchar(512) NULL, reason_code varchar(128) NULL, original_tariff_snapshot_id uuid NULL, review_status varchar(64) NOT NULL,
    reviewer_user_id uuid NULL, reviewer_operator_device_binding_id uuid NULL, reviewer_operator_shift_id uuid NULL, reviewer_access_evaluation_id uuid NULL,
    reviewer_decision varchar(16) NULL, reviewer_decision_reason_code varchar(128) NULL, statutory_discount_validation_id uuid NULL,
    intake_correlation_id uuid NOT NULL, review_correlation_id uuid NULL, submitted_at timestamptz NOT NULL, reviewed_at timestamptz NULL,
    created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT pk_stat_disc_service_channel_reviews PRIMARY KEY (statutory_discount_decision_command_id)
);
ALTER TABLE operator_console.statutory_discount_service_channel_reviews ADD COLUMN IF NOT EXISTS statutory_discount_validation_id uuid NULL;
ALTER TABLE operator_console.statutory_discount_service_channel_reviews
    DROP CONSTRAINT IF EXISTS ck_stat_disc_svc_reviews__source_channel,
    DROP CONSTRAINT IF EXISTS ck_stat_disc_svc_reviews__entitlement_type,
    DROP CONSTRAINT IF EXISTS ck_stat_disc_svc_reviews__review_status,
    DROP CONSTRAINT IF EXISTS ck_stat_disc_svc_reviews__reviewer_decision,
    DROP CONSTRAINT IF EXISTS ck_stat_disc_svc_reviews__review_completion,
    DROP CONSTRAINT IF EXISTS ck_stat_disc_svc_reviews__evidence_json;
ALTER TABLE operator_console.statutory_discount_service_channel_reviews
    ADD CONSTRAINT ck_stat_disc_svc_reviews__source_channel CHECK (source_channel IN ('WEBPAY','ASSISTED_PAYMENT_TERMINAL')),
    ADD CONSTRAINT ck_stat_disc_svc_reviews__entitlement_type CHECK (entitlement_type IN ('SENIOR_CITIZEN','PWD')),
    ADD CONSTRAINT ck_stat_disc_svc_reviews__review_status CHECK (review_status IN ('PENDING_REVIEW','APPROVED','REJECTED','REVIEW_FACTS_UNAVAILABLE')),
    ADD CONSTRAINT ck_stat_disc_svc_reviews__reviewer_decision CHECK (reviewer_decision IS NULL OR reviewer_decision IN ('APPROVE','REJECT')),
    ADD CONSTRAINT ck_stat_disc_svc_reviews__review_completion CHECK ((review_status = 'PENDING_REVIEW' AND reviewer_user_id IS NULL AND reviewer_decision IS NULL AND reviewed_at IS NULL) OR (review_status IN ('APPROVED','REJECTED') AND reviewer_user_id IS NOT NULL AND reviewer_access_evaluation_id IS NOT NULL AND reviewer_decision IS NOT NULL AND reviewed_at IS NOT NULL) OR review_status = 'REVIEW_FACTS_UNAVAILABLE'),
    ADD CONSTRAINT ck_stat_disc_svc_reviews__evidence_json CHECK (jsonb_typeof(evidence_references) = 'array');
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_stat_disc_svc_reviews__decision_command') THEN ALTER TABLE operator_console.statutory_discount_service_channel_reviews ADD CONSTRAINT fk_stat_disc_svc_reviews__decision_command FOREIGN KEY (statutory_discount_decision_command_id) REFERENCES discounts.statutory_discount_decision_commands(statutory_discount_decision_command_id); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_stat_disc_svc_reviews__parking_session') THEN ALTER TABLE operator_console.statutory_discount_service_channel_reviews ADD CONSTRAINT fk_stat_disc_svc_reviews__parking_session FOREIGN KEY (parking_session_id) REFERENCES core.parking_sessions(parking_session_id); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_stat_disc_svc_reviews__site') THEN ALTER TABLE operator_console.statutory_discount_service_channel_reviews ADD CONSTRAINT fk_stat_disc_svc_reviews__site FOREIGN KEY (site_id) REFERENCES sites.sites(site_id); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_stat_disc_svc_reviews__original_tariff_snapshot') THEN ALTER TABLE operator_console.statutory_discount_service_channel_reviews ADD CONSTRAINT fk_stat_disc_svc_reviews__original_tariff_snapshot FOREIGN KEY (original_tariff_snapshot_id) REFERENCES core.tariff_snapshots(tariff_snapshot_id); END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='fk_stat_disc_svc_reviews__validation') THEN ALTER TABLE operator_console.statutory_discount_service_channel_reviews ADD CONSTRAINT fk_stat_disc_svc_reviews__validation FOREIGN KEY (statutory_discount_validation_id) REFERENCES discounts.statutory_discount_validations(statutory_discount_validation_id); END IF;
END $$;
CREATE INDEX IF NOT EXISTS ix_stat_disc_svc_reviews__pending_queue ON operator_console.statutory_discount_service_channel_reviews (review_status, site_id, submitted_at, statutory_discount_decision_command_id) WHERE review_status = 'PENDING_REVIEW';
CREATE INDEX IF NOT EXISTS ix_stat_disc_svc_reviews__source_status ON operator_console.statutory_discount_service_channel_reviews (source_channel, review_status, submitted_at);
CREATE UNIQUE INDEX IF NOT EXISTS ux_stat_disc_svc_reviews__validation ON operator_console.statutory_discount_service_channel_reviews (statutory_discount_validation_id) WHERE statutory_discount_validation_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_stat_disc_svc_reviews__decision_validation ON operator_console.statutory_discount_service_channel_reviews (statutory_discount_decision_command_id, statutory_discount_validation_id) WHERE statutory_discount_validation_id IS NOT NULL;
