-- Create "exit_authorizations" table
CREATE TABLE "core"."exit_authorizations" (
  "exit_authorization_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "parking_session_id" uuid NOT NULL,
  "tariff_snapshot_id" uuid NOT NULL,
  "completion_basis" character varying(64) NOT NULL,
  "completion_authority_reference_id" uuid NOT NULL,
  "payment_attempt_id" uuid NULL,
  "payment_confirmation_id" uuid NULL,
  "statutory_discount_decision_command_id" uuid NULL,
  "statutory_discount_payable_basis_application_command_id" uuid NULL,
  "statutory_discount_validation_id" uuid NULL,
  "applied_policy_reference_id" uuid NULL,
  "statutory_discount_policy_version_id" uuid NULL,
  "authorization_token_hash" character(64) NOT NULL,
  "authorization_status" "core"."exit_authorization_status_enum" NOT NULL,
  "issued_at" timestamptz NOT NULL,
  "expires_at" timestamptz NOT NULL,
  "consumed_at" timestamptz NULL,
  "invalidated_at" timestamptz NULL,
  "invalidation_reason_code" character varying(64) NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_exit_authorizations" PRIMARY KEY ("exit_authorization_id"),
  CONSTRAINT "ck_exit_authorizations__completion_basis" CHECK (completion_basis IN ('PAYMENT_FINALITY', 'ZERO_PAYABLE_STATUTORY_FINALITY')),
  CONSTRAINT "ck_exit_authorizations__consumed_state" CHECK (
    (authorization_status = 'CONSUMED' AND consumed_at IS NOT NULL)
    OR (authorization_status <> 'CONSUMED' AND consumed_at IS NULL)
  ),
  CONSTRAINT "ck_exit_authorizations__completion_ancestry" CHECK (
    (
      completion_basis = 'PAYMENT_FINALITY'
      AND payment_attempt_id IS NOT NULL
      AND payment_confirmation_id IS NOT NULL
      AND completion_authority_reference_id = payment_confirmation_id
      AND statutory_discount_decision_command_id IS NULL
      AND statutory_discount_payable_basis_application_command_id IS NULL
      AND statutory_discount_validation_id IS NULL
      AND applied_policy_reference_id IS NULL
      AND statutory_discount_policy_version_id IS NULL
    )
    OR
    (
      completion_basis = 'ZERO_PAYABLE_STATUTORY_FINALITY'
      AND payment_attempt_id IS NULL
      AND payment_confirmation_id IS NULL
      AND completion_authority_reference_id = statutory_discount_payable_basis_application_command_id
      AND statutory_discount_decision_command_id IS NOT NULL
      AND statutory_discount_payable_basis_application_command_id IS NOT NULL
      AND statutory_discount_validation_id IS NOT NULL
      AND (
        (applied_policy_reference_id IS NOT NULL AND statutory_discount_policy_version_id IS NULL)
        OR
        (applied_policy_reference_id IS NULL AND statutory_discount_policy_version_id IS NOT NULL)
      )
    )
  )
);;

