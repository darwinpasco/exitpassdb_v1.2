-- Create "exit_authorizations" table
CREATE TABLE "core"."exit_authorizations" (
  "exit_authorization_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "parking_session_id" uuid NOT NULL,
  "payment_attempt_id" uuid NOT NULL,
  "payment_confirmation_id" uuid NOT NULL,
  "authorization_token_hash" character(64) NOT NULL,
  "authorization_status" "core"."exit_authorization_status_enum" NOT NULL,
  "issued_at" timestamptz NOT NULL,
  "expires_at" timestamptz NOT NULL,
  "invalidated_at" timestamptz NULL,
  "invalidation_reason_code" character varying(64) NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_exit_authorizations" PRIMARY KEY ("exit_authorization_id")
);;

