-- ExitPass v1.3 Central PMS accepted-live-schema forward alignment.
-- Structural migration only. It does not seed or alter environment configuration records.

BEGIN;

DO $preflight$
BEGIN
    IF to_regclass('core.parking_sessions') IS NULL
       OR to_regclass('core.fiscal_issuance_references') IS NULL
       OR to_regclass('integration.vendor_payment_acknowledgments') IS NULL
       OR to_regclass('operator_console.operator_shifts') IS NULL THEN
        RAISE EXCEPTION 'Missing approved Central PMS canonical prerequisites';
    END IF;

    IF to_regclass('payments.payment_provider_routing_policies') IS NOT NULL
       OR to_regclass('identity.devices') IS NOT NULL
       OR to_regclass('core.terminal_cash_payment_commands') IS NOT NULL
       OR to_regclass('ist_configuration.real_site_catalog_members') IS NOT NULL THEN
        RAISE EXCEPTION 'Alignment target objects already exist or schema is partially aligned';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE (table_schema, table_name, column_name) IN (
            ('integration', 'vendor_payment_acknowledgments', 'completion_basis'),
            ('operator_console', 'operator_shifts', 'shift_reference'),
            ('core', 'payment_attempts', 'payment_method_code')
        )
    ) THEN
        RAISE EXCEPTION 'Alignment target columns already exist or schema is partially aligned';
    END IF;
END
$preflight$;
CREATE SCHEMA "ist_configuration";
-- Modify "fiscal_issuance_references" table
ALTER TABLE "core"."fiscal_issuance_references" ADD CONSTRAINT "ck_fiscal_refs__invoice_customer_fields_normalized" CHECK (((invoice_customer_name IS NULL) OR ((char_length((invoice_customer_name)::text) >= 1) AND (char_length((invoice_customer_name)::text) <= 160) AND ((invoice_customer_name)::text = btrim((invoice_customer_name)::text)))) AND ((invoice_customer_address IS NULL) OR ((char_length((invoice_customer_address)::text) >= 1) AND (char_length((invoice_customer_address)::text) <= 300) AND ((invoice_customer_address)::text = btrim((invoice_customer_address)::text)))) AND ((invoice_customer_tin IS NULL) OR ((char_length((invoice_customer_tin)::text) >= 1) AND (char_length((invoice_customer_tin)::text) <= 40) AND ((invoice_customer_tin)::text = btrim((invoice_customer_tin)::text)))) AND ((invoice_business_style IS NULL) OR ((char_length((invoice_business_style)::text) >= 1) AND (char_length((invoice_business_style)::text) <= 160) AND ((invoice_business_style)::text = btrim((invoice_business_style)::text))))), ADD CONSTRAINT "ck_fiscal_refs__invoice_customer_snapshot_state" CHECK (((invoice_customer_information_snapshot_captured_at IS NULL) AND (invoice_customer_information_row_version IS NULL) AND (invoice_customer_name IS NULL) AND (invoice_customer_address IS NULL) AND (invoice_customer_tin IS NULL) AND (invoice_business_style IS NULL)) OR ((invoice_customer_information_snapshot_captured_at IS NOT NULL) AND (((invoice_customer_information_row_version IS NULL) AND (((invoice_customer_name IS NULL) AND (invoice_customer_address IS NULL) AND (invoice_customer_tin IS NULL) AND (invoice_business_style IS NULL)) OR ((invoice_customer_name IS NOT NULL) AND (invoice_customer_address IS NULL) AND (invoice_customer_tin IS NULL) AND (invoice_business_style IS NULL)))) OR ((invoice_customer_information_row_version > 0) AND ((invoice_customer_name IS NOT NULL) OR (invoice_customer_address IS NOT NULL) OR (invoice_customer_tin IS NOT NULL) OR (invoice_business_style IS NOT NULL)))))), ADD COLUMN "invoice_customer_name" character varying(160) NULL, ADD COLUMN "invoice_customer_address" character varying(300) NULL, ADD COLUMN "invoice_customer_tin" character varying(40) NULL, ADD COLUMN "invoice_business_style" character varying(160) NULL, ADD COLUMN "invoice_customer_information_row_version" bigint NULL, ADD COLUMN "invoice_customer_information_snapshot_captured_at" timestamptz NULL;
-- Set comment to column: "completion_basis" on table: "fiscal_issuance_references"
COMMENT ON COLUMN "core"."fiscal_issuance_references"."completion_basis" IS 'Canonical completion basis: PAYMENT_FINALITY or ZERO_PAYABLE_STATUTORY_FINALITY.';
-- Set comment to column: "completion_authority_reference_id" on table: "fiscal_issuance_references"
COMMENT ON COLUMN "core"."fiscal_issuance_references"."completion_authority_reference_id" IS 'Durable Central PMS source establishing transaction completion.';
-- Set comment to column: "statutory_discount_policy_version_id" on table: "fiscal_issuance_references"
COMMENT ON COLUMN "core"."fiscal_issuance_references"."statutory_discount_policy_version_id" IS 'Canonical immutable policy version for statutory completion; legacy applied-policy references remain separate.';
-- Set comment to column: "invoice_customer_information_row_version" on table: "fiscal_issuance_references"
COMMENT ON COLUMN "core"."fiscal_issuance_references"."invoice_customer_information_row_version" IS 'Authoritative parking-session customer-information row version captured for this fiscal issuance; null when the captured basis was empty.';
-- Set comment to column: "invoice_customer_information_snapshot_captured_at" on table: "fiscal_issuance_references"
COMMENT ON COLUMN "core"."fiscal_issuance_references"."invoice_customer_information_snapshot_captured_at" IS 'Non-null when the immutable parking-session Sales Invoice customer-information basis, including an intentional empty basis, was captured.';
-- Create enum type "device_credential_status_enum"
CREATE TYPE "identity"."device_credential_status_enum" AS ENUM ('ACTIVE', 'REVOKED', 'EXPIRED');
-- Create enum type "device_lifecycle_status_enum"
CREATE TYPE "identity"."device_lifecycle_status_enum" AS ENUM ('REGISTERED', 'PROVISIONING_PENDING', 'ACTIVE', 'SUSPENDED', 'CREDENTIAL_ROTATION', 'REPLACED', 'REVOKED');
-- Create enum type "device_provisioning_purpose_enum"
CREATE TYPE "identity"."device_provisioning_purpose_enum" AS ENUM ('ENROLLMENT', 'ROTATION', 'REPLACEMENT');
-- Create enum type "device_provisioning_status_enum"
CREATE TYPE "identity"."device_provisioning_status_enum" AS ENUM ('ISSUED', 'CONSUMED', 'CANCELLED', 'EXPIRED');
-- Create enum type "device_type_enum"
CREATE TYPE "identity"."device_type_enum" AS ENUM ('OPERATOR_CONSOLE', 'ASSISTED_PAYMENT_TERMINAL');
-- Modify "vendor_payment_acknowledgments" table
ALTER TABLE integration.vendor_payment_acknowledgments
    ADD COLUMN completion_basis varchar(64),
    ADD COLUMN completion_authority_reference_id uuid;

UPDATE integration.vendor_payment_acknowledgments
SET completion_basis = 'PAYMENT_FINALITY',
    completion_authority_reference_id = payment_confirmation_id;

DO $vendor_backfill$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM integration.vendor_payment_acknowledgments
        WHERE payment_attempt_id IS NULL
           OR payment_confirmation_id IS NULL
           OR completion_authority_reference_id IS DISTINCT FROM payment_confirmation_id
    ) THEN
        RAISE EXCEPTION 'Existing vendor acknowledgment completion ancestry is incomplete';
    END IF;
END
$vendor_backfill$;

ALTER TABLE integration.vendor_payment_acknowledgments
    ALTER COLUMN payment_attempt_id DROP NOT NULL,
    ALTER COLUMN payment_confirmation_id DROP NOT NULL,
    ALTER COLUMN completion_basis SET NOT NULL,
    ALTER COLUMN completion_authority_reference_id SET NOT NULL,
    ADD CONSTRAINT ck_vendor_payment_ack__completion_ancestry CHECK (
        (completion_basis = 'PAYMENT_FINALITY'
         AND payment_attempt_id IS NOT NULL
         AND payment_confirmation_id IS NOT NULL
         AND completion_authority_reference_id = payment_confirmation_id)
        OR
        (completion_basis = 'ZERO_PAYABLE_STATUTORY_FINALITY'
         AND payment_attempt_id IS NULL
         AND payment_confirmation_id IS NULL)
    );
-- Create index "uq_vendor_payment_ack__completion_authority_vendor" to table: "vendor_payment_acknowledgments"
CREATE UNIQUE INDEX "uq_vendor_payment_ack__completion_authority_vendor" ON "integration"."vendor_payment_acknowledgments" ("completion_authority_reference_id", "vendor_system_code");
-- Add value to enum type: "operator_action_type_enum"
ALTER TYPE "operations"."operator_action_type_enum" ADD VALUE 'SHIFT_START';
-- Add value to enum type: "operator_action_type_enum"
ALTER TYPE "operations"."operator_action_type_enum" ADD VALUE 'SHIFT_RESUME';
-- Add value to enum type: "operator_action_type_enum"
ALTER TYPE "operations"."operator_action_type_enum" ADD VALUE 'SHIFT_CLOSE';
-- Add value to enum type: "operator_action_type_enum"
ALTER TYPE "operations"."operator_action_type_enum" ADD VALUE 'SHIFT_EXCEPTION_CLOSE';
-- Add value to enum type: "operator_action_type_enum"
ALTER TYPE "operations"."operator_action_type_enum" ADD VALUE 'SHIFT_ACTION_DENIED';
-- Drop index "ux_policy_import_review_submissions__active_fingerprint" from table: "production_policy_import_review_submissions"
DROP INDEX "operator_console"."ux_policy_import_review_submissions__active_fingerprint";
-- Create index "ux_policy_import_review_submissions__active_fingerprint" to table: "production_policy_import_review_submissions"
CREATE UNIQUE INDEX "ux_policy_import_review_submissions__active_fingerprint" ON "operator_console"."production_policy_import_review_submissions" ("maker_operator_id", "submission_fingerprint") WHERE ((review_status)::text <> ALL (ARRAY[('REJECTED'::character varying)::text, ('CANCELLED'::character varying)::text, ('SUPERSEDED'::character varying)::text]));
-- Create "payment_provider_routing_policies" table
CREATE TABLE "payments"."payment_provider_routing_policies" (
  "payment_routing_policy_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "site_id" uuid NULL,
  "site_group_id" uuid NULL,
  "payment_method_code" character varying(32) NOT NULL,
  "primary_provider_code" character varying(64) NOT NULL,
  "fallback_provider_code" character varying(64) NULL,
  "currency_code" character(3) NOT NULL,
  "min_amount_minor_units" bigint NULL,
  "max_amount_minor_units" bigint NULL,
  "is_enabled" boolean NOT NULL DEFAULT true,
  "primary_provider_enabled" boolean NOT NULL DEFAULT true,
  "fallback_provider_enabled" boolean NOT NULL DEFAULT true,
  "effective_from" timestamptz NOT NULL DEFAULT now(),
  "effective_until" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_payment_provider_routing_policies" PRIMARY KEY ("payment_routing_policy_id"),
  CONSTRAINT "ck_payment_provider_routing_policies__amount_bounds" CHECK ((min_amount_minor_units IS NULL) OR (max_amount_minor_units IS NULL) OR (max_amount_minor_units >= min_amount_minor_units)),
  CONSTRAINT "ck_payment_provider_routing_policies__effective_window" CHECK ((effective_until IS NULL) OR (effective_until > effective_from)),
  CONSTRAINT "ck_payment_provider_routing_policies__row_version_positive" CHECK (row_version > 0)
);
-- Create index "ix_payment_provider_routing_policies__lookup" to table: "payment_provider_routing_policies"
CREATE INDEX "ix_payment_provider_routing_policies__lookup" ON "payments"."payment_provider_routing_policies" ("payment_method_code", "currency_code", "is_enabled", "effective_from", "effective_until");
-- Create index "uq_payment_provider_routing_policies__default_method_currency" to table: "payment_provider_routing_policies"
CREATE UNIQUE INDEX "uq_payment_provider_routing_policies__default_method_currency" ON "payments"."payment_provider_routing_policies" ("payment_method_code", "currency_code") WHERE ((site_id IS NULL) AND (site_group_id IS NULL) AND (min_amount_minor_units IS NULL) AND (max_amount_minor_units IS NULL));
-- Set comment to table: "payment_provider_routing_policies"
COMMENT ON TABLE "payments"."payment_provider_routing_policies" IS 'Payment provider routing policy for Payment Orchestrator provider selection.';
-- Set comment to column: "payment_method_code" on table: "payment_provider_routing_policies"
COMMENT ON COLUMN "payments"."payment_provider_routing_policies"."payment_method_code" IS 'Customer-selected payment method code, for example QRPH, CARD, GCASH, or MAYA.';
-- Set comment to column: "primary_provider_code" on table: "payment_provider_routing_policies"
COMMENT ON COLUMN "payments"."payment_provider_routing_policies"."primary_provider_code" IS 'Primary provider selected when no valid preferred provider is supplied.';
-- Set comment to column: "fallback_provider_code" on table: "payment_provider_routing_policies"
COMMENT ON COLUMN "payments"."payment_provider_routing_policies"."fallback_provider_code" IS 'Fallback provider selected when the primary provider is disabled and fallback is enabled.';
-- Set comment to column: "primary_provider_enabled" on table: "payment_provider_routing_policies"
COMMENT ON COLUMN "payments"."payment_provider_routing_policies"."primary_provider_enabled" IS 'Controls whether the configured primary provider is selectable.';
-- Set comment to column: "fallback_provider_enabled" on table: "payment_provider_routing_policies"
COMMENT ON COLUMN "payments"."payment_provider_routing_policies"."fallback_provider_enabled" IS 'Controls whether the configured fallback provider is selectable.';
-- Set comment to column: "health_status" on table: "vendor_session_projection_sync_targets"
COMMENT ON COLUMN "sessions"."vendor_session_projection_sync_targets"."health_status" IS 'Operational target health: HEALTHY, DEGRADED, FAILING, DISABLED, or UNKNOWN.';
-- Create "devices" table
CREATE TABLE "identity"."devices" (
  "device_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "device_reference" character varying(64) NOT NULL,
  "service_identity_id" uuid NOT NULL,
  "device_name" character varying(128) NOT NULL,
  "device_type" "identity"."device_type_enum" NOT NULL,
  "device_description" character varying(512) NULL,
  "terminal_identifier" character varying(128) NULL,
  "lifecycle_status" "identity"."device_lifecycle_status_enum" NOT NULL,
  "credential_version" bigint NOT NULL DEFAULT 0,
  "last_provisioning_status" "identity"."device_provisioning_status_enum" NULL,
  "enrolled_at" timestamptz NULL,
  "suspended_at" timestamptz NULL,
  "revoked_at" timestamptz NULL,
  "replaced_at" timestamptz NULL,
  "replacement_device_id" uuid NULL,
  "predecessor_device_id" uuid NULL,
  "effective_from" timestamptz NOT NULL DEFAULT now(),
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  "terminal_serial_number" character varying(128) NULL,
  CONSTRAINT "pk_devices" PRIMARY KEY ("device_id"),
  CONSTRAINT "uq_devices__device_reference" UNIQUE ("device_reference"),
  CONSTRAINT "uq_devices__service_identity" UNIQUE ("service_identity_id"),
  CONSTRAINT "fk_devices__created_by" FOREIGN KEY ("created_by_user_id") REFERENCES "identity"."users" ("user_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "fk_devices__predecessor" FOREIGN KEY ("predecessor_device_id") REFERENCES "identity"."devices" ("device_id") ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT "fk_devices__replacement" FOREIGN KEY ("replacement_device_id") REFERENCES "identity"."devices" ("device_id") ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT "fk_devices__service_identity" FOREIGN KEY ("service_identity_id") REFERENCES "identity"."service_identities" ("service_identity_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "fk_devices__updated_by" FOREIGN KEY ("updated_by_user_id") REFERENCES "identity"."users" ("user_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "ck_devices__apt_terminal_serial_number_nonblank" CHECK ((device_type <> 'ASSISTED_PAYMENT_TERMINAL'::identity.device_type_enum) OR (terminal_serial_number IS NULL) OR (btrim((terminal_serial_number)::text) <> ''::text)),
  CONSTRAINT "ck_devices__credential_version" CHECK (credential_version >= 0),
  CONSTRAINT "ck_devices__row_version" CHECK (row_version > 0),
  CONSTRAINT "ck_devices__terminal_identifier" CHECK ((device_type <> 'ASSISTED_PAYMENT_TERMINAL'::identity.device_type_enum) OR (terminal_identifier IS NOT NULL)),
  CONSTRAINT "ck_devices__terminal_state" CHECK (((lifecycle_status = 'REVOKED'::identity.device_lifecycle_status_enum) AND (revoked_at IS NOT NULL)) OR ((lifecycle_status = 'REPLACED'::identity.device_lifecycle_status_enum) AND (replaced_at IS NOT NULL) AND (replacement_device_id IS NOT NULL)) OR (lifecycle_status <> ALL (ARRAY['REVOKED'::identity.device_lifecycle_status_enum, 'REPLACED'::identity.device_lifecycle_status_enum])))
);
-- Create index "ix_devices__predecessor" to table: "devices"
CREATE INDEX "ix_devices__predecessor" ON "identity"."devices" ("predecessor_device_id") WHERE (predecessor_device_id IS NOT NULL);
-- Create index "ix_devices__type_status" to table: "devices"
CREATE INDEX "ix_devices__type_status" ON "identity"."devices" ("device_type", "lifecycle_status", "updated_at" DESC);
-- Create index "uq_devices__live_apt_terminal_serial_number" to table: "devices"
CREATE UNIQUE INDEX "uq_devices__live_apt_terminal_serial_number" ON "identity"."devices" ((lower(btrim((terminal_serial_number)::text)))) WHERE ((device_type = 'ASSISTED_PAYMENT_TERMINAL'::identity.device_type_enum) AND (lifecycle_status <> ALL (ARRAY['REVOKED'::identity.device_lifecycle_status_enum, 'REPLACED'::identity.device_lifecycle_status_enum])) AND (terminal_serial_number IS NOT NULL));
-- Set comment to table: "devices"
COMMENT ON TABLE "identity"."devices" IS 'Governed v1.3 device lifecycle extension over canonical identity.service_identities.';
-- Set comment to column: "terminal_serial_number" on table: "devices"
COMMENT ON COLUMN "identity"."devices"."terminal_serial_number" IS 'Persistent physical workstation serial number, distinct from terminal_identifier and immutable fiscal identities.';
-- Create "device_provisioning_credentials" table
CREATE TABLE "identity"."device_provisioning_credentials" (
  "device_provisioning_credential_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "device_id" uuid NOT NULL,
  "token_hash" character(64) NOT NULL,
  "provisioning_purpose" "identity"."device_provisioning_purpose_enum" NOT NULL,
  "provisioning_status" "identity"."device_provisioning_status_enum" NOT NULL,
  "intended_device_type" "identity"."device_type_enum" NOT NULL,
  "intended_site_id" uuid NOT NULL,
  "intended_site_group_id" uuid NULL,
  "intended_credential_version" bigint NOT NULL,
  "issued_at" timestamptz NOT NULL,
  "expires_at" timestamptz NOT NULL,
  "consumed_at" timestamptz NULL,
  "cancelled_at" timestamptz NULL,
  "issued_by_user_id" uuid NOT NULL,
  "cancellation_reason_code" character varying(64) NULL,
  "correlation_id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT "pk_device_provisioning_credentials" PRIMARY KEY ("device_provisioning_credential_id"),
  CONSTRAINT "uq_device_provisioning_credentials__token_hash" UNIQUE ("token_hash"),
  CONSTRAINT "fk_device_provisioning_credentials__device" FOREIGN KEY ("device_id") REFERENCES "identity"."devices" ("device_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "fk_device_provisioning_credentials__issuer" FOREIGN KEY ("issued_by_user_id") REFERENCES "identity"."users" ("user_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "fk_device_provisioning_credentials__site" FOREIGN KEY ("intended_site_id") REFERENCES "sites"."sites" ("site_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "fk_device_provisioning_credentials__site_group" FOREIGN KEY ("intended_site_group_id") REFERENCES "sites"."site_groups" ("site_group_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "ck_device_provisioning_credentials__state" CHECK (((provisioning_status = 'CONSUMED'::identity.device_provisioning_status_enum) AND (consumed_at IS NOT NULL) AND (cancelled_at IS NULL)) OR ((provisioning_status = 'CANCELLED'::identity.device_provisioning_status_enum) AND (cancelled_at IS NOT NULL) AND (consumed_at IS NULL)) OR ((provisioning_status = ANY (ARRAY['ISSUED'::identity.device_provisioning_status_enum, 'EXPIRED'::identity.device_provisioning_status_enum])) AND (consumed_at IS NULL))),
  CONSTRAINT "ck_device_provisioning_credentials__version" CHECK (intended_credential_version > 0),
  CONSTRAINT "ck_device_provisioning_credentials__window" CHECK (expires_at > issued_at)
);
-- Create index "ix_device_provisioning_credentials__device_history" to table: "device_provisioning_credentials"
CREATE INDEX "ix_device_provisioning_credentials__device_history" ON "identity"."device_provisioning_credentials" ("device_id", "issued_at" DESC);
-- Create index "ux_device_provisioning_credentials__one_issued" to table: "device_provisioning_credentials"
CREATE UNIQUE INDEX "ux_device_provisioning_credentials__one_issued" ON "identity"."device_provisioning_credentials" ("device_id") WHERE (provisioning_status = 'ISSUED'::identity.device_provisioning_status_enum);
-- Create "device_credential_history" table
CREATE TABLE "identity"."device_credential_history" (
  "device_credential_history_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "device_id" uuid NOT NULL,
  "credential_version" bigint NOT NULL,
  "credential_type" "identity"."service_credential_type_enum" NOT NULL,
  "credential_status" "identity"."device_credential_status_enum" NOT NULL,
  "credential_fingerprint" character(64) NOT NULL,
  "activated_at" timestamptz NOT NULL,
  "expires_at" timestamptz NULL,
  "revoked_at" timestamptz NULL,
  "revocation_reason_code" character varying(64) NULL,
  "provisioning_credential_id" uuid NULL,
  "correlation_id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT "pk_device_credential_history" PRIMARY KEY ("device_credential_history_id"),
  CONSTRAINT "uq_device_credential_history__version" UNIQUE ("device_id", "credential_version"),
  CONSTRAINT "fk_device_credential_history__device" FOREIGN KEY ("device_id") REFERENCES "identity"."devices" ("device_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "fk_device_credential_history__provisioning" FOREIGN KEY ("provisioning_credential_id") REFERENCES "identity"."device_provisioning_credentials" ("device_provisioning_credential_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "ck_device_credential_history__state" CHECK (((credential_status = 'REVOKED'::identity.device_credential_status_enum) AND (revoked_at IS NOT NULL)) OR (credential_status <> 'REVOKED'::identity.device_credential_status_enum)),
  CONSTRAINT "ck_device_credential_history__version" CHECK (credential_version > 0)
);
-- Create index "ux_device_credential_history__active_fingerprint" to table: "device_credential_history"
CREATE UNIQUE INDEX "ux_device_credential_history__active_fingerprint" ON "identity"."device_credential_history" ("credential_fingerprint") WHERE (credential_status = 'ACTIVE'::identity.device_credential_status_enum);
-- Create index "ux_device_credential_history__one_active" to table: "device_credential_history"
CREATE UNIQUE INDEX "ux_device_credential_history__one_active" ON "identity"."device_credential_history" ("device_id") WHERE (credential_status = 'ACTIVE'::identity.device_credential_status_enum);
-- Create "device_lifecycle_history" table
CREATE TABLE "identity"."device_lifecycle_history" (
  "device_lifecycle_history_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "device_id" uuid NOT NULL,
  "action_code" character varying(64) NOT NULL,
  "previous_status" "identity"."device_lifecycle_status_enum" NULL,
  "resulting_status" "identity"."device_lifecycle_status_enum" NOT NULL,
  "site_id" uuid NOT NULL,
  "site_group_id" uuid NULL,
  "previous_credential_version" bigint NULL,
  "resulting_credential_version" bigint NOT NULL,
  "actor_user_id" uuid NULL,
  "actor_service_identity_id" uuid NULL,
  "reason_code" character varying(64) NULL,
  "correlation_id" uuid NOT NULL,
  "occurred_at" timestamptz NOT NULL,
  CONSTRAINT "pk_device_lifecycle_history" PRIMARY KEY ("device_lifecycle_history_id"),
  CONSTRAINT "fk_device_lifecycle_history__actor_service" FOREIGN KEY ("actor_service_identity_id") REFERENCES "identity"."service_identities" ("service_identity_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "fk_device_lifecycle_history__actor_user" FOREIGN KEY ("actor_user_id") REFERENCES "identity"."users" ("user_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "fk_device_lifecycle_history__device" FOREIGN KEY ("device_id") REFERENCES "identity"."devices" ("device_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "fk_device_lifecycle_history__site" FOREIGN KEY ("site_id") REFERENCES "sites"."sites" ("site_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "fk_device_lifecycle_history__site_group" FOREIGN KEY ("site_group_id") REFERENCES "sites"."site_groups" ("site_group_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "ck_device_lifecycle_history__actor" CHECK ((((actor_user_id IS NOT NULL))::integer + ((actor_service_identity_id IS NOT NULL))::integer) = 1)
);
-- Create index "ix_device_lifecycle_history__device_time" to table: "device_lifecycle_history"
CREATE INDEX "ix_device_lifecycle_history__device_time" ON "identity"."device_lifecycle_history" ("device_id", "occurred_at" DESC);
-- Modify "statutory_discount_validations" table
ALTER TABLE "discounts"."statutory_discount_validations" ADD CONSTRAINT "ck_stat_disc_validations__id_control_reference_valid" CHECK ((id_control_reference IS NULL) OR ((char_length((id_control_reference)::text) >= 4) AND (char_length((id_control_reference)::text) <= 64) AND ((id_control_reference)::text = btrim((id_control_reference)::text)) AND ((id_control_reference)::text !~ '[[:space:]]'::text) AND (POSITION(('*'::text) IN (id_control_reference)) = 0))), ADD COLUMN "birth_date" date NULL, ADD COLUMN "id_control_reference" character varying(64) NULL;
-- Set comment to column: "id_control_reference" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."id_control_reference" IS 'Complete normalized statutory ID/control reference finalized by an authorized reviewer. Presentation masking is applied outside persistence.';
-- Modify "exit_authorizations" table
ALTER TABLE "core"."exit_authorizations" ADD CONSTRAINT "fk_exit_authorizations__applied_policy_reference_id" FOREIGN KEY ("applied_policy_reference_id") REFERENCES "discounts"."discount_policy_references" ("discount_policy_reference_id") ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE, ADD CONSTRAINT "fk_exit_authorizations__policy_version_id" FOREIGN KEY ("statutory_discount_policy_version_id") REFERENCES "discounts"."statutory_discount_policy_versions" ("statutory_discount_policy_version_id") ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE, ADD CONSTRAINT "fk_exit_authorizations__statutory_application_command_id" FOREIGN KEY ("statutory_discount_payable_basis_application_command_id") REFERENCES "discounts"."statutory_discount_payable_basis_application_commands" ("statutory_discount_payable_basis_application_command_id") ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE, ADD CONSTRAINT "fk_exit_authorizations__statutory_decision_command_id" FOREIGN KEY ("statutory_discount_decision_command_id") REFERENCES "discounts"."statutory_discount_decision_commands" ("statutory_discount_decision_command_id") ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE, ADD CONSTRAINT "fk_exit_authorizations__statutory_validation_id" FOREIGN KEY ("statutory_discount_validation_id") REFERENCES "discounts"."statutory_discount_validations" ("statutory_discount_validation_id") ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE;
-- Create index "ux_exit_authorizations__statutory_application_command" to table: "exit_authorizations"
CREATE UNIQUE INDEX "ux_exit_authorizations__statutory_application_command" ON "core"."exit_authorizations" ("statutory_discount_payable_basis_application_command_id") WHERE (statutory_discount_payable_basis_application_command_id IS NOT NULL);
-- Set comment to column: "tariff_snapshot_id" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."tariff_snapshot_id" IS 'Immutable payable basis for which completion was established.';
-- Set comment to column: "completion_basis" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."completion_basis" IS 'Canonical completion basis: PAYMENT_FINALITY or ZERO_PAYABLE_STATUTORY_FINALITY.';
-- Set comment to column: "completion_authority_reference_id" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."completion_authority_reference_id" IS 'Durable authority identifier for the selected completion basis.';
-- Set comment to column: "payment_attempt_id" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."payment_attempt_id" IS 'Confirmed payment attempt supporting PAYMENT_FINALITY; null for statutory zero-payable completion.';
-- Set comment to column: "payment_confirmation_id" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."payment_confirmation_id" IS 'Recorded confirmation supporting PAYMENT_FINALITY; null for statutory zero-payable completion.';
-- Set comment to column: "statutory_discount_decision_command_id" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."statutory_discount_decision_command_id" IS 'Approved statutory decision backing zero-payable completion.';
-- Set comment to column: "statutory_discount_payable_basis_application_command_id" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."statutory_discount_payable_basis_application_command_id" IS 'Applied zero-payable basis command backing statutory completion.';
-- Set comment to column: "statutory_discount_validation_id" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."statutory_discount_validation_id" IS 'Approved statutory validation backing zero-payable completion.';
-- Set comment to column: "applied_policy_reference_id" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."applied_policy_reference_id" IS 'Legacy applied policy reference backing zero-payable completion.';
-- Set comment to column: "statutory_discount_policy_version_id" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."statutory_discount_policy_version_id" IS 'Canonical immutable policy version backing zero-payable completion; legacy policy references remain separate.';
-- Set comment to column: "consumed_at" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."consumed_at" IS 'Timestamp when the authorization was consumed through the canonical completion path.';
-- Modify "operator_shifts" table
ALTER TABLE operator_console.operator_shifts
    ALTER COLUMN hr_provider_code DROP NOT NULL,
    ALTER COLUMN external_shift_id_hash DROP NOT NULL,
    ALTER COLUMN hr_identity_mapping_id DROP NOT NULL,
    ALTER COLUMN scheduled_start_at DROP NOT NULL,
    ALTER COLUMN scheduled_end_at DROP NOT NULL,
    ALTER COLUMN source_imported_at DROP NOT NULL,
    ALTER COLUMN import_status_code DROP NOT NULL,
    ALTER COLUMN source_system_code DROP NOT NULL,
    ADD COLUMN shift_reference varchar(64),
    ADD COLUMN shift_origin varchar(32) NOT NULL DEFAULT 'HR_IMPORT',
    ADD COLUMN operator_device_binding_id uuid,
    ADD COLUMN terminal_reference varchar(128),
    ADD COLUMN opened_at timestamptz,
    ADD COLUMN opened_by_user_id uuid,
    ADD COLUMN closed_at timestamptz,
    ADD COLUMN closed_by_user_id uuid,
    ADD COLUMN close_type varchar(32),
    ADD COLUMN close_reason text,
    ADD COLUMN cash_custody_status varchar(32) NOT NULL DEFAULT 'NONE',
    ADD COLUMN cash_custody_session_id uuid,
    ADD COLUMN opening_cash_minor_units bigint;

UPDATE operator_console.operator_shifts
SET shift_reference = 'SHIFT-' || upper(replace(operator_shift_id::text, '-', '')),
    opened_at = COALESCE(active_from, scheduled_start_at, created_at),
    closed_at = CASE
        WHEN operational_status IN ('ENDED', 'REVOKED', 'TAKEN_OVER', 'CANCELLED')
            THEN COALESCE(active_to, revoked_at, updated_at)
        ELSE NULL
    END;

ALTER TABLE operator_console.operator_shifts
    ALTER COLUMN shift_reference SET NOT NULL,
    ALTER COLUMN opened_at SET NOT NULL,
    ADD CONSTRAINT ck_operator_shifts__cash_custody_status CHECK (
        cash_custody_status::text = ANY (ARRAY[
            'NONE'::varchar::text,
            'OPEN'::varchar::text,
            'CLOSED'::varchar::text,
            'UNAVAILABLE'::varchar::text
        ])
    ),
    ADD CONSTRAINT ck_operator_shifts__close_fields CHECK ((operational_status = 'ACTIVE' AND closed_at IS NULL AND close_type IS NULL) OR operational_status <> 'ACTIVE'),
    ADD CONSTRAINT ck_operator_shifts__shift_origin CHECK (
        shift_origin::text = ANY (ARRAY[
            'OPERATOR_STARTED'::varchar::text,
            'HR_IMPORT'::varchar::text
        ])
    ),
    ADD CONSTRAINT fk_operator_shifts__closed_by_user_id FOREIGN KEY (closed_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE,
    ADD CONSTRAINT fk_operator_shifts__opened_by_user_id FOREIGN KEY (opened_by_user_id) REFERENCES identity.users(user_id) DEFERRABLE,
    ADD CONSTRAINT fk_operator_shifts__operator_device_binding_id FOREIGN KEY (operator_device_binding_id) REFERENCES operator_console.operator_device_bindings(operator_device_binding_id) DEFERRABLE;
-- Create index "ix_operator_shifts__site_operational_history" to table: "operator_shifts"
CREATE INDEX "ix_operator_shifts__site_operational_history" ON "operator_console"."operator_shifts" ("site_id", "operational_status", "opened_at" DESC);
-- Create index "ux_operator_shifts__one_active_per_user" to table: "operator_shifts"
CREATE UNIQUE INDEX "ux_operator_shifts__one_active_per_user" ON "operator_console"."operator_shifts" ("operator_user_id") WHERE ((operational_status = 'ACTIVE'::operator_console.operator_shift_operational_status_enum) AND (revoked_at IS NULL));
-- Create index "ux_operator_shifts__shift_reference" to table: "operator_shifts"
CREATE UNIQUE INDEX "ux_operator_shifts__shift_reference" ON "operator_console"."operator_shifts" ("shift_reference");
-- Set comment to table: "operator_shifts"
COMMENT ON TABLE "operator_console"."operator_shifts" IS 'Authoritative operational accountability shifts. HR-import metadata is optional and does not gate operator-started shifts.';
-- Set comment to column: "cash_custody_status" on table: "operator_shifts"
COMMENT ON COLUMN "operator_console"."operator_shifts"."cash_custody_status" IS 'Observed custody state kept distinct from shift lifecycle; an OPEN value blocks all shift closure.';
-- Create "operator_session_contexts" table
CREATE TABLE "operator_console"."operator_session_contexts" (
  "operator_session_context_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "human_session_id" uuid NOT NULL,
  "operator_user_id" uuid NOT NULL,
  "operator_device_binding_id" uuid NOT NULL,
  "operator_shift_id" uuid NULL,
  "site_group_id" uuid NOT NULL,
  "site_id" uuid NOT NULL,
  "authorization_epoch_snapshot" bigint NOT NULL,
  "credential_version_snapshot" bigint NOT NULL,
  "context_status" character varying(32) NOT NULL,
  "bound_at" timestamptz NOT NULL,
  "last_validated_at" timestamptz NOT NULL,
  "invalidated_at" timestamptz NULL,
  "invalidation_reason_code" character varying(96) NULL,
  "correlation_id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_operator_session_contexts" PRIMARY KEY ("operator_session_context_id"),
  CONSTRAINT "ux_operator_session_contexts__human_session" UNIQUE ("human_session_id"),
  CONSTRAINT "fk_operator_session_contexts__device_binding" FOREIGN KEY ("operator_device_binding_id") REFERENCES "operator_console"."operator_device_bindings" ("operator_device_binding_id") ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE,
  CONSTRAINT "fk_operator_session_contexts__human_session" FOREIGN KEY ("human_session_id") REFERENCES "identity"."human_sessions" ("human_session_id") ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE,
  CONSTRAINT "fk_operator_session_contexts__operator_shift" FOREIGN KEY ("operator_shift_id") REFERENCES "operator_console"."operator_shifts" ("operator_shift_id") ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE,
  CONSTRAINT "fk_operator_session_contexts__operator_user" FOREIGN KEY ("operator_user_id") REFERENCES "identity"."users" ("user_id") ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE,
  CONSTRAINT "fk_operator_session_contexts__site" FOREIGN KEY ("site_id") REFERENCES "sites"."sites" ("site_id") ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE,
  CONSTRAINT "fk_operator_session_contexts__site_group" FOREIGN KEY ("site_group_id") REFERENCES "sites"."site_groups" ("site_group_id") ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE,
  CONSTRAINT "ck_operator_session_contexts__epochs_nonnegative" CHECK ((authorization_epoch_snapshot >= 0) AND (credential_version_snapshot >= 0)),
  CONSTRAINT "ck_operator_session_contexts__invalidation" CHECK ((((context_status)::text = 'ACTIVE'::text) AND (invalidated_at IS NULL) AND (invalidation_reason_code IS NULL)) OR (((context_status)::text = 'INVALIDATED'::text) AND (invalidated_at IS NOT NULL) AND (invalidation_reason_code IS NOT NULL))),
  CONSTRAINT "ck_operator_session_contexts__row_version_positive" CHECK (row_version > 0),
  CONSTRAINT "ck_operator_session_contexts__status" CHECK ((context_status)::text = ANY (ARRAY[('ACTIVE'::character varying)::text, ('INVALIDATED'::character varying)::text])),
  CONSTRAINT "ck_operator_session_contexts__validation_time" CHECK (last_validated_at >= bound_at)
);
-- Create index "ix_operator_session_contexts__active_device" to table: "operator_session_contexts"
CREATE INDEX "ix_operator_session_contexts__active_device" ON "operator_console"."operator_session_contexts" ("operator_device_binding_id", "last_validated_at" DESC) WHERE ((context_status)::text = 'ACTIVE'::text);
-- Create index "ix_operator_session_contexts__active_shift" to table: "operator_session_contexts"
CREATE INDEX "ix_operator_session_contexts__active_shift" ON "operator_console"."operator_session_contexts" ("operator_shift_id", "last_validated_at" DESC) WHERE ((context_status)::text = 'ACTIVE'::text);
-- Create index "ix_operator_session_contexts__active_user" to table: "operator_session_contexts"
CREATE INDEX "ix_operator_session_contexts__active_user" ON "operator_console"."operator_session_contexts" ("operator_user_id", "last_validated_at" DESC) WHERE ((context_status)::text = 'ACTIVE'::text);
-- Create index "ix_operator_session_contexts__correlation" to table: "operator_session_contexts"
CREATE INDEX "ix_operator_session_contexts__correlation" ON "operator_console"."operator_session_contexts" ("correlation_id");
-- Set comment to table: "operator_session_contexts"
COMMENT ON TABLE "operator_console"."operator_session_contexts" IS 'Server-owned H-006 Operator Console device and effective Site/Site Group binding; an optional shift reference is retained only for historical compatibility.';
-- Set comment to column: "operator_shift_id" on table: "operator_session_contexts"
COMMENT ON COLUMN "operator_console"."operator_session_contexts"."operator_shift_id" IS 'Optional historical Operator Console shift reference; not part of the v1.3 authorization boundary.';
-- Create "parking_session_invoice_customer_information" table
CREATE TABLE "core"."parking_session_invoice_customer_information" (
  "parking_session_id" uuid NOT NULL,
  "customer_name" character varying(160) NULL,
  "customer_address" character varying(300) NULL,
  "customer_tin" character varying(40) NULL,
  "business_style" character varying(160) NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "created_source_channel" character varying(64) NOT NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "updated_source_channel" character varying(64) NOT NULL,
  CONSTRAINT "pk_parking_session_invoice_customer_information" PRIMARY KEY ("parking_session_id"),
  CONSTRAINT "fk_ps_invoice_customer_information__created_service" FOREIGN KEY ("created_by_service_identity_id") REFERENCES "identity"."service_identities" ("service_identity_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "fk_ps_invoice_customer_information__created_user" FOREIGN KEY ("created_by_user_id") REFERENCES "identity"."users" ("user_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "fk_ps_invoice_customer_information__parking_session" FOREIGN KEY ("parking_session_id") REFERENCES "core"."parking_sessions" ("parking_session_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "fk_ps_invoice_customer_information__updated_service" FOREIGN KEY ("updated_by_service_identity_id") REFERENCES "identity"."service_identities" ("service_identity_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "fk_ps_invoice_customer_information__updated_user" FOREIGN KEY ("updated_by_user_id") REFERENCES "identity"."users" ("user_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "ck_ps_invoice_customer_information__business_style" CHECK ((business_style IS NULL) OR (((business_style)::text = btrim((business_style)::text)) AND ((business_style)::text <> ''::text))),
  CONSTRAINT "ck_ps_invoice_customer_information__created_actor" CHECK (num_nonnulls(created_by_user_id, created_by_service_identity_id) = 1),
  CONSTRAINT "ck_ps_invoice_customer_information__created_source" CHECK ((created_source_channel)::text = ANY (ARRAY[('OPERATOR_CONSOLE'::character varying)::text, ('WEBPAY'::character varying)::text, ('ASSISTED_PAYMENT_TERMINAL'::character varying)::text])),
  CONSTRAINT "ck_ps_invoice_customer_information__customer_address" CHECK ((customer_address IS NULL) OR (((customer_address)::text = btrim((customer_address)::text)) AND ((customer_address)::text <> ''::text))),
  CONSTRAINT "ck_ps_invoice_customer_information__customer_name" CHECK ((customer_name IS NULL) OR (((customer_name)::text = btrim((customer_name)::text)) AND ((customer_name)::text <> ''::text))),
  CONSTRAINT "ck_ps_invoice_customer_information__customer_tin" CHECK ((customer_tin IS NULL) OR (((customer_tin)::text = btrim((customer_tin)::text)) AND ((customer_tin)::text <> ''::text))),
  CONSTRAINT "ck_ps_invoice_customer_information__has_value" CHECK (num_nonnulls(customer_name, customer_address, customer_tin, business_style) > 0),
  CONSTRAINT "ck_ps_invoice_customer_information__row_version" CHECK (row_version > 0),
  CONSTRAINT "ck_ps_invoice_customer_information__timestamps" CHECK (updated_at >= created_at),
  CONSTRAINT "ck_ps_invoice_customer_information__updated_actor" CHECK (num_nonnulls(updated_by_user_id, updated_by_service_identity_id) = 1),
  CONSTRAINT "ck_ps_invoice_customer_information__updated_source" CHECK ((updated_source_channel)::text = ANY (ARRAY[('OPERATOR_CONSOLE'::character varying)::text, ('WEBPAY'::character varying)::text, ('ASSISTED_PAYMENT_TERMINAL'::character varying)::text]))
);
-- Set comment to table: "parking_session_invoice_customer_information"
COMMENT ON TABLE "core"."parking_session_invoice_customer_information" IS 'Central PMS authority for editable pre-issuance Sales Invoice customer information associated with one parking session. Issued fiscal documents use an immutable copied snapshot.';
-- Set comment to column: "row_version" on table: "parking_session_invoice_customer_information"
COMMENT ON COLUMN "core"."parking_session_invoice_customer_information"."row_version" IS 'Optimistic-concurrency version. Identical writes do not advance this value; accepted material changes advance it exactly once.';
-- Set comment to column: "created_source_channel" on table: "parking_session_invoice_customer_information"
COMMENT ON COLUMN "core"."parking_session_invoice_customer_information"."created_source_channel" IS 'Server-derived originating channel. Browser-authored channel authority is prohibited.';
-- Set comment to column: "updated_source_channel" on table: "parking_session_invoice_customer_information"
COMMENT ON COLUMN "core"."parking_session_invoice_customer_information"."updated_source_channel" IS 'Server-derived channel responsible for the latest accepted material change.';
-- Modify "payment_attempts" table
ALTER TABLE "core"."payment_attempts" ADD COLUMN "payment_method_code" character varying(32) NULL;
-- Set comment to column: "payment_method_code" on table: "payment_attempts"
COMMENT ON COLUMN "core"."payment_attempts"."payment_method_code" IS 'Customer-selected payment method kept separate from the internal provider rail.';
-- Drop index "ux_tariff_snapshots__statutory_discount_validation_applied" from table: "tariff_snapshots"
DROP INDEX "core"."ux_tariff_snapshots__statutory_discount_validation_applied";
-- Create index "ux_tariff_snapshots__statutory_discount_validation_applied" to table: "tariff_snapshots"
CREATE UNIQUE INDEX "ux_tariff_snapshots__statutory_discount_validation_applied" ON "core"."tariff_snapshots" ("statutory_discount_validation_id") WHERE ((statutory_discount_validation_id IS NOT NULL) AND (snapshot_status = 'ACTIVE'::core.tariff_snapshot_status_enum));
-- Set comment to index: "ux_tariff_snapshots__statutory_discount_validation_applied" on table: "tariff_snapshots"
COMMENT ON INDEX "core"."ux_tariff_snapshots__statutory_discount_validation_applied" IS 'Allows immutable historical statutory-adjusted revisions while enforcing one ACTIVE adjusted snapshot per validation.';
-- Create "payment_attempt_invoice_customer_information" table
CREATE TABLE "core"."payment_attempt_invoice_customer_information" (
  "payment_attempt_id" uuid NOT NULL,
  "parking_session_id" uuid NOT NULL,
  "tariff_snapshot_id" uuid NOT NULL,
  "customer_name" character varying(160) NULL,
  "customer_address" character varying(300) NULL,
  "customer_tin" character varying(40) NULL,
  "business_style" character varying(160) NULL,
  "statutory_id_number" character varying(80) NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT "pk_payment_attempt_invoice_customer_information" PRIMARY KEY ("payment_attempt_id"),
  CONSTRAINT "fk_payment_attempt_invoice_customer_information__attempt" FOREIGN KEY ("payment_attempt_id") REFERENCES "core"."payment_attempts" ("payment_attempt_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "fk_payment_attempt_invoice_customer_information__session" FOREIGN KEY ("parking_session_id") REFERENCES "core"."parking_sessions" ("parking_session_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "fk_payment_attempt_invoice_customer_information__tariff" FOREIGN KEY ("tariff_snapshot_id") REFERENCES "core"."tariff_snapshots" ("tariff_snapshot_id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Set comment to table: "payment_attempt_invoice_customer_information"
COMMENT ON TABLE "core"."payment_attempt_invoice_customer_information" IS 'Immutable Sales Invoice customer-information snapshot associated with one canonical payment attempt for fiscal issuance and replay. It is not the editable parking-session authority.';
-- Create "real_site_catalog_members" table
CREATE TABLE "ist_configuration"."real_site_catalog_members" (
  "site_id" uuid NOT NULL,
  "site_code" text NOT NULL,
  "source_workbook" text NOT NULL,
  "source_sheet" text NOT NULL,
  "source_row" integer NOT NULL,
  "source_manifest_sha256" text NOT NULL,
  "initialized_at" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY ("site_id"),
  CONSTRAINT "real_site_catalog_members_site_code_key" UNIQUE ("site_code"),
  CONSTRAINT "real_site_catalog_members_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "sites"."sites" ("site_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "ck_real_site_catalog_members__manifest_hash" CHECK (source_manifest_sha256 ~ '^[0-9a-f]{64}$'::text),
  CONSTRAINT "ck_real_site_catalog_members__site_code_not_blank" CHECK (btrim(site_code) <> ''::text)
);
-- Create "site_operational_capabilities" table
CREATE TABLE "ist_configuration"."site_operational_capabilities" (
  "site_id" uuid NOT NULL,
  "operator_entity_code" text NULL,
  "hikcentral_instance_code" text NULL,
  "hikcentral_parking_lot_index_code" text NULL,
  "hikcentral_parking_lot_name" text NULL,
  "hikcentral_target_configured" boolean NOT NULL DEFAULT false,
  "hikcentral_connectivity_verified" boolean NOT NULL DEFAULT false,
  "fiscal_merchant_configured" boolean NOT NULL DEFAULT false,
  "fiscal_supplier_configured" boolean NOT NULL DEFAULT false,
  "fiscal_profile_approved" boolean NOT NULL DEFAULT false,
  "paymongo_enabled" boolean NOT NULL DEFAULT false,
  "pos_site_server_id" uuid NULL,
  "fiscal_identity_id" uuid NULL,
  "sales_invoice_profile_id" uuid NULL,
  "last_verified_at" timestamptz NULL,
  "verification_reference" text NULL,
  "site_adapter_base_url" text NULL,
  "site_adapter_environment_code" text NULL,
  "site_adapter_secret_reference" text NULL,
  "central_pms_service_identity_id" uuid NULL,
  "site_adapter_service_identity_id" uuid NULL,
  "site_adapter_vendor_system_id" uuid NULL,
  "site_adapter_credential_reference_id" uuid NULL,
  "site_adapter_endpoint_id" uuid NULL,
  "site_adapter_mapping_id" uuid NULL,
  PRIMARY KEY ("site_id"),
  CONSTRAINT "site_operational_capabilities_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "ist_configuration"."real_site_catalog_members" ("site_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "ck_site_operational_capabilities__approved_fiscal_complete" CHECK ((NOT fiscal_profile_approved) OR (fiscal_merchant_configured AND fiscal_supplier_configured)),
  CONSTRAINT "ck_site_operational_capabilities__connectivity_requires_target" CHECK ((NOT hikcentral_connectivity_verified) OR hikcentral_target_configured)
);
-- Create "statutory_beneficiary_identities" table
CREATE TABLE "discounts"."statutory_beneficiary_identities" (
  "statutory_beneficiary_identity_id" uuid NOT NULL,
  "statutory_discount_decision_command_id" uuid NOT NULL,
  "site_id" uuid NOT NULL,
  "entitlement_type" character varying(64) NOT NULL,
  "statutory_id_type" character varying(64) NOT NULL,
  "protected_identity_envelope" bytea NOT NULL,
  "protection_key_reference" character varying(128) NOT NULL,
  "protection_key_version" character varying(64) NOT NULL,
  "envelope_format_version" smallint NOT NULL,
  "captured_by_actor_ref" uuid NOT NULL,
  "captured_by_channel" character varying(32) NOT NULL,
  "captured_at" timestamptz NOT NULL,
  "last_updated_by_actor_ref" uuid NOT NULL,
  "last_updated_by_channel" character varying(32) NOT NULL,
  "last_updated_at" timestamptz NOT NULL,
  "reviewed_by_actor_ref" uuid NULL,
  "reviewed_at" timestamptz NULL,
  "approval_decision_reference" character varying(200) NULL,
  "correlation_reference" uuid NOT NULL,
  "is_final" boolean NOT NULL DEFAULT false,
  PRIMARY KEY ("statutory_beneficiary_identity_id"),
  CONSTRAINT "statutory_beneficiary_identit_statutory_discount_decision_c_key" UNIQUE ("statutory_discount_decision_command_id"),
  CONSTRAINT "statutory_beneficiary_identit_statutory_discount_decision__fkey" FOREIGN KEY ("statutory_discount_decision_command_id") REFERENCES "discounts"."statutory_discount_decision_commands" ("statutory_discount_decision_command_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "statutory_beneficiary_identities_captured_by_actor_ref_fkey" FOREIGN KEY ("captured_by_actor_ref") REFERENCES "identity"."users" ("user_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "statutory_beneficiary_identities_last_updated_by_actor_ref_fkey" FOREIGN KEY ("last_updated_by_actor_ref") REFERENCES "identity"."users" ("user_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "statutory_beneficiary_identities_reviewed_by_actor_ref_fkey" FOREIGN KEY ("reviewed_by_actor_ref") REFERENCES "identity"."users" ("user_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "statutory_beneficiary_identities_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "sites"."sites" ("site_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "ck_statutory_beneficiary_identity_capture_channel" CHECK ((captured_by_channel)::text = ANY (ARRAY[('OPERATOR_CONSOLE'::character varying)::text, ('MANAGEMENT_PLATFORM'::character varying)::text])),
  CONSTRAINT "ck_statutory_beneficiary_identity_envelope" CHECK ((octet_length(protected_identity_envelope) >= 31) AND (envelope_format_version > 0)),
  CONSTRAINT "ck_statutory_beneficiary_identity_final" CHECK ((NOT is_final) OR ((reviewed_by_actor_ref IS NOT NULL) AND (reviewed_at IS NOT NULL) AND (approval_decision_reference IS NOT NULL))),
  CONSTRAINT "ck_statutory_beneficiary_identity_update_channel" CHECK ((last_updated_by_channel)::text = ANY (ARRAY[('OPERATOR_CONSOLE'::character varying)::text, ('MANAGEMENT_PLATFORM'::character varying)::text]))
);
-- Create index "ix_statutory_beneficiary_identities__site" to table: "statutory_beneficiary_identities"
CREATE INDEX "ix_statutory_beneficiary_identities__site" ON "discounts"."statutory_beneficiary_identities" ("site_id");
-- Set comment to table: "statutory_beneficiary_identities"
COMMENT ON TABLE "discounts"."statutory_beneficiary_identities" IS 'Purpose-specific encrypted beneficiary identity captured only by Operator Console or Management Platform for final statutory fiscal snapshotting.';
-- Create "statutory_coverage_register" table
CREATE TABLE "ist_configuration"."statutory_coverage_register" (
  "jurisdiction_id" uuid NOT NULL,
  "jurisdiction_code" text NOT NULL,
  "jurisdiction_display_name" text NOT NULL,
  "entitlement_type" text NOT NULL,
  "parking_policy_identified" boolean NOT NULL,
  "benefit_type" text NULL,
  "free_period_minutes" integer NULL,
  "discount_percent" numeric(7,4) NULL,
  "residency_scope" text NULL,
  "ordinance_or_authority_reference" text NULL,
  "ordinance_number_status" text NOT NULL,
  "source_quality_classification" text NOT NULL,
  "operational_verification_status" text NOT NULL,
  "legal_review_status" text NOT NULL,
  "runtime_publication_eligibility" text NOT NULL,
  "manual_review_required" boolean NOT NULL,
  "source_reference" text NOT NULL,
  "notes" text NULL,
  "source_manifest_sha256" text NOT NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY ("jurisdiction_id", "entitlement_type"),
  CONSTRAINT "statutory_coverage_register_jurisdiction_id_fkey" FOREIGN KEY ("jurisdiction_id") REFERENCES "sites"."jurisdictions" ("jurisdiction_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "ck_statutory_coverage_register__entitlement" CHECK (entitlement_type = ANY (ARRAY['SENIOR_CITIZEN'::text, 'PWD'::text])),
  CONSTRAINT "ck_statutory_coverage_register__manifest_hash" CHECK (source_manifest_sha256 ~ '^[0-9a-f]{64}$'::text),
  CONSTRAINT "ck_statutory_coverage_register__unknown_discount" CHECK ((discount_percent IS NULL) OR (discount_percent > (0)::numeric)),
  CONSTRAINT "ck_statutory_coverage_register__unknown_free_period" CHECK ((free_period_minutes IS NULL) OR (free_period_minutes > 0))
);
-- Create "statutory_discount_payable_basis_recalculations" table
CREATE TABLE "discounts"."statutory_discount_payable_basis_recalculations" (
  "statutory_discount_payable_basis_recalculation_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "statutory_discount_payable_basis_application_id" uuid NOT NULL,
  "statutory_discount_validation_id" uuid NOT NULL,
  "parking_session_id" uuid NOT NULL,
  "previous_applied_tariff_snapshot_id" uuid NOT NULL,
  "original_tariff_snapshot_id" uuid NOT NULL,
  "applied_tariff_snapshot_id" uuid NOT NULL,
  "gross_amount_minor_units" bigint NOT NULL,
  "vat_amount_minor_units" bigint NOT NULL,
  "vat_exclusive_amount_minor_units" bigint NOT NULL,
  "statutory_discount_amount_minor_units" bigint NOT NULL,
  "final_payable_amount_minor_units" bigint NOT NULL,
  "currency_code" character(3) NOT NULL,
  "computation_basis_json" jsonb NOT NULL DEFAULT '{}',
  "correlation_id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  CONSTRAINT "pk_statutory_discount_payable_basis_recalculations" PRIMARY KEY ("statutory_discount_payable_basis_recalculation_id"),
  CONSTRAINT "fk_sd_pbr__application" FOREIGN KEY ("statutory_discount_payable_basis_application_id") REFERENCES "discounts"."statutory_discount_payable_basis_applications" ("statutory_discount_payable_basis_application_id") ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE,
  CONSTRAINT "fk_sd_pbr__applied_tariff" FOREIGN KEY ("applied_tariff_snapshot_id") REFERENCES "core"."tariff_snapshots" ("tariff_snapshot_id") ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE,
  CONSTRAINT "fk_sd_pbr__created_by_service_identity" FOREIGN KEY ("created_by_service_identity_id") REFERENCES "identity"."service_identities" ("service_identity_id") ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE,
  CONSTRAINT "fk_sd_pbr__original_tariff" FOREIGN KEY ("original_tariff_snapshot_id") REFERENCES "core"."tariff_snapshots" ("tariff_snapshot_id") ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE,
  CONSTRAINT "fk_sd_pbr__parking_session" FOREIGN KEY ("parking_session_id") REFERENCES "core"."parking_sessions" ("parking_session_id") ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE,
  CONSTRAINT "fk_sd_pbr__previous_applied_tariff" FOREIGN KEY ("previous_applied_tariff_snapshot_id") REFERENCES "core"."tariff_snapshots" ("tariff_snapshot_id") ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE,
  CONSTRAINT "fk_sd_pbr__validation" FOREIGN KEY ("statutory_discount_validation_id") REFERENCES "discounts"."statutory_discount_validations" ("statutory_discount_validation_id") ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE,
  CONSTRAINT "ck_sd_pbr__currency_code" CHECK (((currency_code)::text = upper((currency_code)::text)) AND (currency_code ~ '^[A-Z]{3}$'::text)),
  CONSTRAINT "ck_sd_pbr__discount_not_greater_than_vat_exclusive" CHECK (statutory_discount_amount_minor_units <= vat_exclusive_amount_minor_units),
  CONSTRAINT "ck_sd_pbr__discount_positive" CHECK (statutory_discount_amount_minor_units > 0),
  CONSTRAINT "ck_sd_pbr__distinct_tariffs" CHECK ((previous_applied_tariff_snapshot_id <> original_tariff_snapshot_id) AND (previous_applied_tariff_snapshot_id <> applied_tariff_snapshot_id) AND (original_tariff_snapshot_id <> applied_tariff_snapshot_id)),
  CONSTRAINT "ck_sd_pbr__final_non_negative" CHECK (final_payable_amount_minor_units >= 0),
  CONSTRAINT "ck_sd_pbr__final_not_greater_than_gross" CHECK (final_payable_amount_minor_units <= gross_amount_minor_units),
  CONSTRAINT "ck_sd_pbr__gross_components" CHECK ((vat_exclusive_amount_minor_units + vat_amount_minor_units) = gross_amount_minor_units),
  CONSTRAINT "ck_sd_pbr__gross_positive" CHECK (gross_amount_minor_units > 0),
  CONSTRAINT "ck_sd_pbr__vat_exclusive_non_negative" CHECK (vat_exclusive_amount_minor_units >= 0),
  CONSTRAINT "ck_sd_pbr__vat_non_negative" CHECK (vat_amount_minor_units >= 0)
);
-- Create index "ix_sd_pbr__application_created" to table: "statutory_discount_payable_basis_recalculations"
CREATE INDEX "ix_sd_pbr__application_created" ON "discounts"."statutory_discount_payable_basis_recalculations" ("statutory_discount_payable_basis_application_id", "created_at" DESC);
-- Create index "ux_sd_pbr__applied_tariff" to table: "statutory_discount_payable_basis_recalculations"
CREATE UNIQUE INDEX "ux_sd_pbr__applied_tariff" ON "discounts"."statutory_discount_payable_basis_recalculations" ("applied_tariff_snapshot_id");
-- Create index "ux_sd_pbr__original_tariff" to table: "statutory_discount_payable_basis_recalculations"
CREATE UNIQUE INDEX "ux_sd_pbr__original_tariff" ON "discounts"."statutory_discount_payable_basis_recalculations" ("original_tariff_snapshot_id");
-- Create index "ux_sd_pbr__previous_applied_tariff" to table: "statutory_discount_payable_basis_recalculations"
CREATE UNIQUE INDEX "ux_sd_pbr__previous_applied_tariff" ON "discounts"."statutory_discount_payable_basis_recalculations" ("previous_applied_tariff_snapshot_id");
-- Set comment to table: "statutory_discount_payable_basis_recalculations"
COMMENT ON TABLE "discounts"."statutory_discount_payable_basis_recalculations" IS 'Append-only evidence for recalculating an already applied statutory full-fee benefit from a changed authoritative vendor tariff.';
-- Modify "statutory_discount_service_channel_reviews" table
ALTER TABLE "operator_console"."statutory_discount_service_channel_reviews" DROP CONSTRAINT "ck_stat_disc_svc_reviews__source_channel", ADD CONSTRAINT "ck_stat_disc_svc_reviews__source_channel" CHECK ((source_channel)::text = ANY (ARRAY[('WEBPAY'::character varying)::text, ('ASSISTED_PAYMENT_TERMINAL'::character varying)::text, ('OPERATOR_CONSOLE'::character varying)::text])), ADD CONSTRAINT "ck_stat_disc_svc_reviews__id_control_reference_valid" CHECK ((id_control_reference IS NULL) OR ((char_length((id_control_reference)::text) >= 4) AND (char_length((id_control_reference)::text) <= 64) AND ((id_control_reference)::text = btrim((id_control_reference)::text)) AND ((id_control_reference)::text !~ '[[:space:]]'::text) AND (POSITION(('*'::text) IN (id_control_reference)) = 0))), ADD CONSTRAINT "ck_stat_disc_svc_reviews__operator_entitlement_date" CHECK (((source_channel)::text <> 'OPERATOR_CONSOLE'::text) OR (((entitlement_type)::text = 'SENIOR_CITIZEN'::text) AND (birth_date IS NOT NULL)) OR (((entitlement_type)::text = 'PWD'::text) AND (expiry_date IS NOT NULL))), ADD CONSTRAINT "ck_stat_disc_svc_reviews__operator_submitter" CHECK ((((source_channel)::text = 'OPERATOR_CONSOLE'::text) AND (submitted_by_user_id IS NOT NULL)) OR (((source_channel)::text = ANY (ARRAY[('WEBPAY'::character varying)::text, ('ASSISTED_PAYMENT_TERMINAL'::character varying)::text])) AND (submitted_by_user_id IS NULL))), ADD COLUMN "birth_date" date NULL, ADD COLUMN "submitted_by_user_id" uuid NULL, ADD COLUMN "id_control_reference" character varying(64) NULL, ADD CONSTRAINT "fk_stat_disc_svc_reviews__submitted_user" FOREIGN KEY ("submitted_by_user_id") REFERENCES "identity"."users" ("user_id") ON UPDATE NO ACTION ON DELETE NO ACTION;
-- Set comment to column: "id_control_reference" on table: "statutory_discount_service_channel_reviews"
COMMENT ON COLUMN "operator_console"."statutory_discount_service_channel_reviews"."id_control_reference" IS 'Complete normalized statutory ID/control reference submitted by the customer and correctable by an authorized reviewer. Public presentation must use masked_id_reference.';
-- Create "terminal_cash_payment_commands" table
CREATE TABLE "core"."terminal_cash_payment_commands" (
  "terminal_cash_payment_command_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "terminal_cash_tender_id" uuid NOT NULL,
  "cash_custody_session_id" uuid NOT NULL,
  "parking_session_id" uuid NOT NULL,
  "tariff_snapshot_id" uuid NOT NULL,
  "cashier_id" character varying(128) NOT NULL,
  "cashier_session_reference" character varying(256) NOT NULL,
  "cashier_shift_id" character varying(128) NOT NULL,
  "terminal_id" character varying(128) NOT NULL,
  "site_id" uuid NOT NULL,
  "site_group_id" uuid NOT NULL,
  "pos_server_id" character varying(128) NOT NULL,
  "currency_code" character(3) NOT NULL,
  "amount_due_minor_units" bigint NOT NULL,
  "amount_tendered_minor_units" bigint NOT NULL,
  "change_due_minor_units" bigint NOT NULL,
  "cash_received_at" timestamptz NOT NULL,
  "denomination_entries" jsonb NOT NULL DEFAULT '[]',
  "local_event_reference" character varying(256) NOT NULL,
  "idempotency_key" character varying(128) NOT NULL,
  "idempotency_scope" character varying(256) NOT NULL,
  "semantic_request_hash" character varying(80) NOT NULL,
  "semantic_hash_source_version" character varying(32) NOT NULL,
  "original_correlation_id" uuid NOT NULL,
  "payment_attempt_id" uuid NOT NULL,
  "payment_confirmation_id" uuid NOT NULL,
  "canonical_payment_status" character varying(64) NOT NULL,
  "result_classification" character varying(64) NOT NULL,
  "fiscal_status" character varying(64) NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "confirmed_at" timestamptz NOT NULL,
  "last_updated_at" timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT "pk_terminal_cash_payment_commands" PRIMARY KEY ("terminal_cash_payment_command_id"),
  CONSTRAINT "fk_terminal_cash_payment_commands__parking_session_id" FOREIGN KEY ("parking_session_id") REFERENCES "core"."parking_sessions" ("parking_session_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "fk_terminal_cash_payment_commands__payment_attempt_id" FOREIGN KEY ("payment_attempt_id") REFERENCES "core"."payment_attempts" ("payment_attempt_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "fk_terminal_cash_payment_commands__payment_confirmation_id" FOREIGN KEY ("payment_confirmation_id") REFERENCES "core"."payment_confirmations" ("payment_confirmation_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "fk_terminal_cash_payment_commands__tariff_snapshot_id" FOREIGN KEY ("tariff_snapshot_id") REFERENCES "core"."tariff_snapshots" ("tariff_snapshot_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "ck_terminal_cash_payment_commands__amounts" CHECK ((amount_due_minor_units > 0) AND (amount_tendered_minor_units >= amount_due_minor_units) AND (change_due_minor_units = (amount_tendered_minor_units - amount_due_minor_units))),
  CONSTRAINT "ck_terminal_cash_payment_commands__classification" CHECK ((result_classification)::text = ANY (ARRAY[('CREATED'::character varying)::text, ('IDEMPOTENT_REPLAY'::character varying)::text])),
  CONSTRAINT "ck_terminal_cash_payment_commands__currency" CHECK (((currency_code)::text = upper((currency_code)::text)) AND (length(currency_code) = 3)),
  CONSTRAINT "ck_terminal_cash_payment_commands__fiscal_status" CHECK ((fiscal_status)::text = 'NOT_STARTED_IN_THIS_SLICE'::text),
  CONSTRAINT "ck_terminal_cash_payment_commands__hash" CHECK ((semantic_request_hash)::text ~ '^sha256:[0-9a-f]{64}$'::text),
  CONSTRAINT "ck_terminal_cash_payment_commands__semantic_version" CHECK ((semantic_hash_source_version)::text = 'terminal-cash-payment:sha256:v1'::text)
);
-- Create index "ix_terminal_cash_payment_commands__correlation" to table: "terminal_cash_payment_commands"
CREATE INDEX "ix_terminal_cash_payment_commands__correlation" ON "core"."terminal_cash_payment_commands" ("original_correlation_id");
-- Create index "ix_terminal_cash_payment_commands__parking_session" to table: "terminal_cash_payment_commands"
CREATE INDEX "ix_terminal_cash_payment_commands__parking_session" ON "core"."terminal_cash_payment_commands" ("parking_session_id");
-- Create index "ix_terminal_cash_payment_commands__tariff_snapshot" to table: "terminal_cash_payment_commands"
CREATE INDEX "ix_terminal_cash_payment_commands__tariff_snapshot" ON "core"."terminal_cash_payment_commands" ("tariff_snapshot_id");
-- Create index "ux_terminal_cash_payment_commands__idempotency" to table: "terminal_cash_payment_commands"
CREATE UNIQUE INDEX "ux_terminal_cash_payment_commands__idempotency" ON "core"."terminal_cash_payment_commands" ("idempotency_scope", "idempotency_key");
-- Create index "ux_terminal_cash_payment_commands__payment_attempt" to table: "terminal_cash_payment_commands"
CREATE UNIQUE INDEX "ux_terminal_cash_payment_commands__payment_attempt" ON "core"."terminal_cash_payment_commands" ("payment_attempt_id");
-- Create index "ux_terminal_cash_payment_commands__payment_confirmation" to table: "terminal_cash_payment_commands"
CREATE UNIQUE INDEX "ux_terminal_cash_payment_commands__payment_confirmation" ON "core"."terminal_cash_payment_commands" ("payment_confirmation_id");
-- Create index "ux_terminal_cash_payment_commands__terminal_tender" to table: "terminal_cash_payment_commands"
CREATE UNIQUE INDEX "ux_terminal_cash_payment_commands__terminal_tender" ON "core"."terminal_cash_payment_commands" ("terminal_id", "site_id", "terminal_cash_tender_id");
-- Set comment to table: "terminal_cash_payment_commands"
COMMENT ON TABLE "core"."terminal_cash_payment_commands" IS 'Durable Central PMS evidence for terminal cash-payment commands and idempotent readback. This table records backend acceptance of terminal-local cash evidence; it does not perform fiscal issuance, issue exit authorization, or command gates.';
-- Create "terminal_cash_payment_command_audits" table
CREATE TABLE "core"."terminal_cash_payment_command_audits" (
  "terminal_cash_payment_command_audit_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "terminal_cash_payment_command_id" uuid NULL,
  "terminal_cash_tender_id" uuid NOT NULL,
  "audit_event_type" character varying(64) NOT NULL,
  "error_code" character varying(128) NULL,
  "correlation_id" uuid NOT NULL,
  "occurred_at" timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT "pk_terminal_cash_payment_command_audits" PRIMARY KEY ("terminal_cash_payment_command_audit_id"),
  CONSTRAINT "fk_terminal_cash_payment_command_audits__command" FOREIGN KEY ("terminal_cash_payment_command_id") REFERENCES "core"."terminal_cash_payment_commands" ("terminal_cash_payment_command_id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "ck_terminal_cash_payment_command_audits__event" CHECK ((audit_event_type)::text = ANY (ARRAY[('ACCEPTED'::character varying)::text, ('IDEMPOTENT_REPLAY'::character varying)::text, ('SEMANTIC_CONFLICT'::character varying)::text, ('REJECTED'::character varying)::text]))
);
-- Create index "ix_terminal_cash_payment_command_audits__correlation" to table: "terminal_cash_payment_command_audits"
CREATE INDEX "ix_terminal_cash_payment_command_audits__correlation" ON "core"."terminal_cash_payment_command_audits" ("correlation_id");
-- Create index "ix_terminal_cash_payment_command_audits__tender" to table: "terminal_cash_payment_command_audits"
CREATE INDEX "ix_terminal_cash_payment_command_audits__tender" ON "core"."terminal_cash_payment_command_audits" ("terminal_cash_tender_id");

--
-- Name: enforce_exit_authorization_completion_ancestry(); Type: FUNCTION; Schema: core; Owner: -
--

CREATE FUNCTION core.enforce_exit_authorization_completion_ancestry() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_attempt_tariff_snapshot_id uuid;
    v_confirmation_attempt_id uuid;
BEGIN
    IF NEW.completion_basis IS NULL AND
       NEW.payment_attempt_id IS NOT NULL AND
       NEW.payment_confirmation_id IS NOT NULL THEN
        NEW.completion_basis := 'PAYMENT_FINALITY';
    END IF;

    IF NEW.completion_authority_reference_id IS NULL AND
       NEW.completion_basis = 'PAYMENT_FINALITY' THEN
        NEW.completion_authority_reference_id := NEW.payment_confirmation_id;
    END IF;

    IF NEW.completion_basis = 'PAYMENT_FINALITY' THEN
        IF NEW.payment_attempt_id IS NULL OR NEW.payment_confirmation_id IS NULL OR
           NEW.completion_authority_reference_id IS DISTINCT FROM NEW.payment_confirmation_id OR
           NEW.statutory_discount_decision_command_id IS NOT NULL OR
           NEW.statutory_discount_payable_basis_application_command_id IS NOT NULL OR
           NEW.statutory_discount_validation_id IS NOT NULL OR
           NEW.applied_policy_reference_id IS NOT NULL OR
           NEW.statutory_discount_policy_version_id IS NOT NULL THEN
            RAISE EXCEPTION 'PAYMENT_FINALITY exit authorization has invalid completion ancestry'
                USING ERRCODE = '23514';
        END IF;

        SELECT tariff_snapshot_id
        INTO v_attempt_tariff_snapshot_id
        FROM core.payment_attempts
        WHERE payment_attempt_id = NEW.payment_attempt_id;

        SELECT payment_attempt_id
        INTO v_confirmation_attempt_id
        FROM core.payment_confirmations
        WHERE payment_confirmation_id = NEW.payment_confirmation_id
          AND confirmation_status = 'RECORDED';

        IF v_attempt_tariff_snapshot_id IS NULL OR
           v_confirmation_attempt_id IS DISTINCT FROM NEW.payment_attempt_id OR
           (NEW.tariff_snapshot_id IS NOT NULL AND
            NEW.tariff_snapshot_id IS DISTINCT FROM v_attempt_tariff_snapshot_id) THEN
            RAISE EXCEPTION 'PAYMENT_FINALITY exit authorization ancestry does not reconcile'
                USING ERRCODE = '23514';
        END IF;

        NEW.tariff_snapshot_id := v_attempt_tariff_snapshot_id;
    ELSIF NEW.completion_basis = 'ZERO_PAYABLE_STATUTORY_FINALITY' THEN
        IF NEW.payment_attempt_id IS NOT NULL OR NEW.payment_confirmation_id IS NOT NULL OR
           NEW.tariff_snapshot_id IS NULL OR
           NEW.completion_authority_reference_id IS DISTINCT FROM
               NEW.statutory_discount_payable_basis_application_command_id OR
           NEW.statutory_discount_decision_command_id IS NULL OR
           NEW.statutory_discount_payable_basis_application_command_id IS NULL OR
           NEW.statutory_discount_validation_id IS NULL OR
           (NEW.applied_policy_reference_id IS NULL AND
            NEW.statutory_discount_policy_version_id IS NULL) OR
           (NEW.applied_policy_reference_id IS NOT NULL AND
            NEW.statutory_discount_policy_version_id IS NOT NULL) THEN
            RAISE EXCEPTION 'ZERO_PAYABLE_STATUTORY_FINALITY exit authorization has invalid completion ancestry'
                USING ERRCODE = '23514';
        END IF;
    ELSE
        RAISE EXCEPTION 'unsupported ExitAuthorization completion basis: %', NEW.completion_basis
            USING ERRCODE = '23514';
    END IF;

    RETURN NEW;
END;
$$;

--
-- Name: reject_final_statutory_beneficiary_identity_mutation(); Type: FUNCTION; Schema: discounts; Owner: -
--

CREATE FUNCTION discounts.reject_final_statutory_beneficiary_identity_mutation() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF OLD.is_final THEN
        RAISE EXCEPTION 'final statutory beneficiary identity is immutable'
            USING ERRCODE = 'check_violation';
    END IF;
    RETURN NEW;
END;
$$;

--
-- Name: reject_statutory_discount_payable_basis_recalculation_mutation(); Type: FUNCTION; Schema: discounts; Owner: -
--

CREATE FUNCTION discounts.reject_statutory_discount_payable_basis_recalculation_mutation() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    RAISE EXCEPTION 'statutory payable-basis recalculation evidence is immutable'
        USING ERRCODE = '23514';
END;
$$;

--
-- Name: resolve_real_site(text); Type: FUNCTION; Schema: ist_configuration; Owner: -
--

CREATE FUNCTION ist_configuration.resolve_real_site(p_site_code text) RETURNS TABLE(site_id uuid, site_code text, site_name text, site_group_id uuid, site_group_name text, jurisdiction_id uuid, jurisdiction_code text, jurisdiction_name text)
    LANGUAGE sql STABLE STRICT
    AS $$
    SELECT site.site_id, site.site_code::text, site.site_name::text,
           site_group.site_group_id, site_group.site_group_name::text,
           jurisdiction.jurisdiction_id, jurisdiction.jurisdiction_code::text,
           jurisdiction.display_name::text
    FROM ist_configuration.real_site_catalog_members member
    JOIN sites.sites site ON site.site_id = member.site_id
    JOIN sites.site_groups site_group ON site_group.site_group_id = site.site_group_id
    JOIN sites.site_jurisdiction_assignments assignment
      ON assignment.site_id = site.site_id
     AND assignment.assignment_status = 'ACTIVE'
     AND assignment.effective_to IS NULL
    JOIN sites.jurisdictions jurisdiction ON jurisdiction.jurisdiction_id = assignment.jurisdiction_id
    WHERE site.site_code = upper(btrim(p_site_code));
$$;

--
-- Name: effective_site_adapter_routes; Type: VIEW; Schema: ist_configuration; Owner: -
--

CREATE VIEW ist_configuration.effective_site_adapter_routes AS
 SELECT capability.site_id,
    mapping.site_group_id,
    vendor.vendor_system_id,
    endpoint.vendor_endpoint_id,
    mapping.adapter_mapping_id,
    credential.integration_credential_reference_id,
    adapter.service_identity_id AS adapter_service_identity_id,
    credential.service_identity_id AS central_pms_service_identity_id,
    vendor.base_url_ref,
    vendor.environment_code,
    credential.secret_reference
   FROM (((((ist_configuration.site_operational_capabilities capability
     JOIN integration.adapter_mappings mapping ON (((mapping.site_id = capability.site_id) AND ((mapping.vendor_object_type)::text = 'SITE_ADAPTER'::text))))
     JOIN integration.vendor_systems vendor ON ((vendor.vendor_system_id = mapping.vendor_system_id)))
     JOIN integration.vendor_endpoints endpoint ON (((endpoint.vendor_system_id = vendor.vendor_system_id) AND ((endpoint.endpoint_code)::text = 'SITE_ADAPTER_API'::text))))
     JOIN integration.integration_credential_references credential ON ((credential.integration_credential_reference_id = endpoint.credential_reference_id)))
     JOIN identity.service_identities adapter ON ((adapter.service_identity_id =
        CASE
            WHEN ((mapping.vendor_object_ref)::text ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'::text) THEN (mapping.vendor_object_ref)::uuid
            ELSE NULL::uuid
        END)))
  WHERE ((mapping.site_group_id = ( SELECT sites.site_group_id
           FROM sites.sites
          WHERE (sites.site_id = capability.site_id))) AND ((mapping.mapping_status)::text = 'ACTIVE'::text) AND ((vendor.vendor_system_status)::text = 'ACTIVE'::text) AND ((endpoint.endpoint_status)::text = 'ACTIVE'::text) AND ((credential.credential_status)::text = 'ACTIVE'::text) AND (credential.service_identity_id = capability.central_pms_service_identity_id) AND ((adapter.identity_status)::text = 'ACTIVE'::text) AND ((vendor.environment_code)::text = capability.site_adapter_environment_code) AND ((vendor.base_url_ref)::text ~* '^https?://[^[:space:]]+/?$'::text) AND ((credential.secret_reference)::text ~* '^file:[^[:space:]]+$'::text) AND (vendor.effective_from <= now()) AND ((vendor.effective_to IS NULL) OR (vendor.effective_to > now())) AND (endpoint.effective_from <= now()) AND ((endpoint.effective_to IS NULL) OR (endpoint.effective_to > now())) AND (mapping.effective_from <= now()) AND ((mapping.effective_to IS NULL) OR (mapping.effective_to > now())) AND (credential.revoked_at IS NULL) AND ((credential.expires_at IS NULL) OR (credential.expires_at > now())));

--
-- Name: site_adapter_route_readiness; Type: VIEW; Schema: ist_configuration; Owner: -
--

CREATE VIEW ist_configuration.site_adapter_route_readiness AS
 SELECT capability.site_id,
    count(route.vendor_system_id) AS effective_route_count,
    ((count(route.vendor_system_id) = 1) AND ((min((route.vendor_system_id)::text))::uuid = capability.site_adapter_vendor_system_id) AND ((min((route.vendor_endpoint_id)::text))::uuid = capability.site_adapter_endpoint_id) AND ((min((route.adapter_mapping_id)::text))::uuid = capability.site_adapter_mapping_id) AND ((min((route.integration_credential_reference_id)::text))::uuid = capability.site_adapter_credential_reference_id) AND ((min((route.adapter_service_identity_id)::text))::uuid = capability.site_adapter_service_identity_id) AND ((min((route.central_pms_service_identity_id)::text))::uuid = capability.central_pms_service_identity_id) AND (min((route.base_url_ref)::text) = capability.site_adapter_base_url) AND (min((route.environment_code)::text) = capability.site_adapter_environment_code) AND (min((route.secret_reference)::text) = capability.site_adapter_secret_reference)) AS site_adapter_route_ready,
    (min((route.vendor_system_id)::text))::uuid AS vendor_system_id,
    (min((route.vendor_endpoint_id)::text))::uuid AS endpoint_id,
    (min((route.adapter_mapping_id)::text))::uuid AS mapping_id,
    (min((route.integration_credential_reference_id)::text))::uuid AS credential_reference_id,
    (min((route.adapter_service_identity_id)::text))::uuid AS adapter_service_identity_id,
    (min((route.central_pms_service_identity_id)::text))::uuid AS central_pms_service_identity_id,
    min((route.base_url_ref)::text) AS base_url,
    min((route.environment_code)::text) AS environment_code
   FROM (ist_configuration.site_operational_capabilities capability
     LEFT JOIN ist_configuration.effective_site_adapter_routes route USING (site_id))
  GROUP BY capability.site_id, capability.site_adapter_vendor_system_id, capability.site_adapter_endpoint_id, capability.site_adapter_mapping_id, capability.site_adapter_credential_reference_id, capability.site_adapter_service_identity_id, capability.central_pms_service_identity_id, capability.site_adapter_base_url, capability.site_adapter_environment_code, capability.site_adapter_secret_reference;

--
-- Name: projection_target_route_readiness; Type: VIEW; Schema: ist_configuration; Owner: -
--

CREATE VIEW ist_configuration.projection_target_route_readiness AS
 SELECT capability.site_id,
    (count(target.projection_sync_target_id) FILTER (WHERE target.enabled_flag) > 0) AS projection_target_required,
    count(target.projection_sync_target_id) FILTER (WHERE target.enabled_flag) AS enabled_projection_target_count,
        CASE
            WHEN (count(target.projection_sync_target_id) FILTER (WHERE target.enabled_flag) = 0) THEN true
            WHEN (count(target.projection_sync_target_id) FILTER (WHERE target.enabled_flag) = 1) THEN COALESCE((bool_and((target.site_group_id = site.site_group_id)) FILTER (WHERE target.enabled_flag) AND bool_and((target.vendor_system_id = route.vendor_system_id)) FILTER (WHERE target.enabled_flag) AND bool_and((target.parking_lot_index_code = capability.hikcentral_parking_lot_index_code)) FILTER (WHERE target.enabled_flag) AND route.site_adapter_route_ready), false)
            ELSE false
        END AS projection_target_route_aligned,
    (min((target.projection_sync_target_id)::text) FILTER (WHERE target.enabled_flag))::uuid AS projection_sync_target_id,
    (min((target.vendor_system_id)::text) FILTER (WHERE target.enabled_flag))::uuid AS projection_target_vendor_system_id,
    min(target.parking_lot_index_code) FILTER (WHERE target.enabled_flag) AS projection_target_parking_lot_index_code,
    min(target.health_status) FILTER (WHERE target.enabled_flag) AS projection_target_health_status,
    max(target.last_success_at) FILTER (WHERE target.enabled_flag) AS projection_target_last_success_at,
        CASE
            WHEN (count(target.projection_sync_target_id) FILTER (WHERE target.enabled_flag) = 0) THEN NULL::boolean
            WHEN (count(target.projection_sync_target_id) FILTER (WHERE target.enabled_flag) = 1) THEN bool_and(((target.health_status = 'HEALTHY'::text) AND (target.last_success_at IS NOT NULL) AND (target.last_success_at >= target.updated_at))) FILTER (WHERE target.enabled_flag)
            ELSE false
        END AS projection_target_runtime_healthy
   FROM (((ist_configuration.site_operational_capabilities capability
     JOIN sites.sites site USING (site_id))
     JOIN ist_configuration.site_adapter_route_readiness route USING (site_id))
     LEFT JOIN sessions.vendor_session_projection_sync_targets target USING (site_id))
  GROUP BY capability.site_id, capability.hikcentral_parking_lot_index_code, site.site_group_id, route.vendor_system_id, route.site_adapter_route_ready;

--
-- Name: real_site_readiness; Type: VIEW; Schema: ist_configuration; Owner: -
--

CREATE VIEW ist_configuration.real_site_readiness AS
 WITH policy AS (
         SELECT statutory_coverage_register.jurisdiction_id,
            max(
                CASE
                    WHEN (statutory_coverage_register.entitlement_type = 'SENIOR_CITIZEN'::text) THEN
                    CASE
                        WHEN (statutory_coverage_register.operational_verification_status = 'VERIFIED_ACTIVE_OPERATIONAL'::text) THEN 'ACTIVE_MANUAL_REVIEW'::text
                        WHEN statutory_coverage_register.parking_policy_identified THEN 'RESEARCH_COVERAGE_REVIEW_REQUIRED'::text
                        ELSE 'NO_LOCAL_POLICY_IDENTIFIED'::text
                    END
                    ELSE NULL::text
                END) AS senior_policy_status,
            max(
                CASE
                    WHEN (statutory_coverage_register.entitlement_type = 'PWD'::text) THEN
                    CASE
                        WHEN (statutory_coverage_register.operational_verification_status = 'VERIFIED_ACTIVE_OPERATIONAL'::text) THEN 'ACTIVE_MANUAL_REVIEW'::text
                        WHEN statutory_coverage_register.parking_policy_identified THEN 'RESEARCH_COVERAGE_REVIEW_REQUIRED'::text
                        ELSE 'NO_LOCAL_POLICY_IDENTIFIED'::text
                    END
                    ELSE NULL::text
                END) AS pwd_policy_status
           FROM ist_configuration.statutory_coverage_register
          GROUP BY statutory_coverage_register.jurisdiction_id
        )
 SELECT member.site_id,
    member.site_code,
    site.site_name,
    site.site_group_id,
    site_group.site_group_name,
    jurisdiction.jurisdiction_code,
    jurisdiction.display_name AS jurisdiction,
    (site.site_status = 'ACTIVE'::sites.site_status_enum) AS site_exists_active,
    (site_group.site_group_status = 'ACTIVE'::sites.site_group_status_enum) AS site_group_exists_active,
    (assignment.assignment_status = 'ACTIVE'::sites.site_jurisdiction_assignment_status_enum) AS jurisdiction_active,
    policy.senior_policy_status,
    policy.pwd_policy_status,
    capability.hikcentral_target_configured,
    capability.hikcentral_connectivity_verified,
    site.public_lookup_enabled AS webpay_public_lookup_enabled,
    site.payment_enabled AS webpay_payment_enabled,
    capability.fiscal_merchant_configured,
    capability.fiscal_supplier_configured,
    capability.fiscal_profile_approved,
    capability.paymongo_enabled,
        CASE
            WHEN ((site.site_status = 'ACTIVE'::sites.site_status_enum) AND (site_group.site_group_status = 'ACTIVE'::sites.site_group_status_enum) AND (assignment.assignment_status = 'ACTIVE'::sites.site_jurisdiction_assignment_status_enum) AND capability.hikcentral_connectivity_verified AND route.site_adapter_route_ready AND projection.projection_target_route_aligned AND site.public_lookup_enabled AND site.payment_enabled AND capability.fiscal_profile_approved AND capability.paymongo_enabled) THEN 'READY'::text
            WHEN ((site.site_status = 'ACTIVE'::sites.site_status_enum) AND (site_group.site_group_status = 'ACTIVE'::sites.site_group_status_enum) AND (assignment.assignment_status = 'ACTIVE'::sites.site_jurisdiction_assignment_status_enum)) THEN 'PARTIALLY_CONFIGURED'::text
            ELSE 'CONFIGURATION_REQUIRED'::text
        END AS final_test_readiness,
    route.effective_route_count AS site_adapter_route_count,
    route.site_adapter_route_ready,
    projection.projection_target_required,
    projection.enabled_projection_target_count,
    projection.projection_target_route_aligned,
    projection.projection_sync_target_id,
    projection.projection_target_vendor_system_id,
    projection.projection_target_parking_lot_index_code,
    projection.projection_target_health_status,
    projection.projection_target_last_success_at,
    projection.projection_target_runtime_healthy
   FROM ((((((((ist_configuration.real_site_catalog_members member
     JOIN sites.sites site ON ((site.site_id = member.site_id)))
     JOIN sites.site_groups site_group ON ((site_group.site_group_id = site.site_group_id)))
     JOIN sites.site_jurisdiction_assignments assignment ON (((assignment.site_id = site.site_id) AND (assignment.assignment_status = 'ACTIVE'::sites.site_jurisdiction_assignment_status_enum) AND (assignment.effective_to IS NULL))))
     JOIN sites.jurisdictions jurisdiction ON ((jurisdiction.jurisdiction_id = assignment.jurisdiction_id)))
     JOIN ist_configuration.site_operational_capabilities capability ON ((capability.site_id = site.site_id)))
     JOIN ist_configuration.site_adapter_route_readiness route ON ((route.site_id = site.site_id)))
     JOIN ist_configuration.projection_target_route_readiness projection ON ((projection.site_id = site.site_id)))
     LEFT JOIN policy ON ((policy.jurisdiction_id = jurisdiction.jurisdiction_id)));

--
-- Name: real_site_operational_readiness; Type: VIEW; Schema: ist_configuration; Owner: -
--

CREATE VIEW ist_configuration.real_site_operational_readiness AS
 SELECT readiness.site_id,
    readiness.site_code,
    readiness.site_name,
    readiness.site_group_id,
    readiness.site_group_name,
    readiness.jurisdiction,
    readiness.senior_policy_status,
    readiness.pwd_policy_status,
    capability.operator_entity_code,
    capability.hikcentral_instance_code,
    capability.hikcentral_target_configured,
    capability.hikcentral_connectivity_verified,
    capability.hikcentral_parking_lot_index_code,
    capability.hikcentral_parking_lot_name,
    readiness.webpay_public_lookup_enabled,
    readiness.webpay_payment_enabled,
    capability.fiscal_merchant_configured,
    capability.fiscal_supplier_configured,
    capability.fiscal_profile_approved,
    capability.pos_site_server_id,
    capability.fiscal_identity_id,
    capability.sales_invoice_profile_id,
    capability.paymongo_enabled,
    readiness.final_test_readiness,
    capability.last_verified_at,
    capability.verification_reference,
    readiness.site_adapter_route_count,
    readiness.site_adapter_route_ready,
    capability.site_adapter_base_url,
    capability.site_adapter_environment_code,
    capability.central_pms_service_identity_id,
    capability.site_adapter_service_identity_id,
    capability.site_adapter_vendor_system_id,
    capability.site_adapter_credential_reference_id,
    capability.site_adapter_endpoint_id,
    capability.site_adapter_mapping_id,
    readiness.projection_target_required,
    readiness.enabled_projection_target_count,
    readiness.projection_target_route_aligned,
    readiness.projection_sync_target_id,
    readiness.projection_target_vendor_system_id,
    readiness.projection_target_parking_lot_index_code,
    readiness.projection_target_health_status,
    readiness.projection_target_last_success_at,
    readiness.projection_target_runtime_healthy
   FROM (ist_configuration.real_site_readiness readiness
     JOIN ist_configuration.site_operational_capabilities capability USING (site_id));

--
-- Name: exit_authorizations trg_exit_authorizations_completion_ancestry; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_exit_authorizations_completion_ancestry BEFORE INSERT OR UPDATE OF tariff_snapshot_id, completion_basis, completion_authority_reference_id, payment_attempt_id, payment_confirmation_id, statutory_discount_decision_command_id, statutory_discount_payable_basis_application_command_id, statutory_discount_validation_id, applied_policy_reference_id, statutory_discount_policy_version_id ON core.exit_authorizations FOR EACH ROW EXECUTE FUNCTION core.enforce_exit_authorization_completion_ancestry();

--
-- Name: statutory_discount_payable_basis_recalculations trg_sd_pbr__immutable; Type: TRIGGER; Schema: discounts; Owner: -
--

CREATE TRIGGER trg_sd_pbr__immutable BEFORE DELETE OR UPDATE ON discounts.statutory_discount_payable_basis_recalculations FOR EACH ROW EXECUTE FUNCTION discounts.reject_statutory_discount_payable_basis_recalculation_mutation();

--
-- Name: statutory_beneficiary_identities trg_statutory_beneficiary_identity_final_immutable; Type: TRIGGER; Schema: discounts; Owner: -
--

CREATE TRIGGER trg_statutory_beneficiary_identity_final_immutable BEFORE DELETE OR UPDATE ON discounts.statutory_beneficiary_identities FOR EACH ROW EXECUTE FUNCTION discounts.reject_final_statutory_beneficiary_identity_mutation();

COMMIT;
