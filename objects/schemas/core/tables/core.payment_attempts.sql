-- Create "payment_attempts" table
CREATE TABLE "core"."payment_attempts" (
  "payment_attempt_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "parking_session_id" uuid NOT NULL,
  "tariff_snapshot_id" uuid NOT NULL,
  "idempotency_key" character varying(128) NOT NULL,
  "payment_rail_id" uuid NULL,
  "currency_code" character(3) NOT NULL,
  "amount" numeric(18,2) NOT NULL,
  "attempt_status" "core"."payment_attempt_status_enum" NOT NULL,
  "requested_at" timestamptz NOT NULL,
  "expires_at" timestamptz NOT NULL,
  "finalized_at" timestamptz NULL,
  "failure_reason_code" character varying(64) NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_payment_attempts" PRIMARY KEY ("payment_attempt_id")
);;

