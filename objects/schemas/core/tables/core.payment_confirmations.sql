-- Create "payment_confirmations" table
CREATE TABLE "core"."payment_confirmations" (
  "payment_confirmation_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "payment_attempt_id" uuid NOT NULL,
  "provider_outcome_id" uuid NULL,
  "payment_rail_id" uuid NULL,
  "provider_transaction_ref" character varying(128) NULL,
  "currency_code" character(3) NOT NULL,
  "confirmed_amount" numeric(18,2) NOT NULL,
  "confirmation_status" "core"."payment_confirmation_status_enum" NOT NULL,
  "verified_at" timestamptz NOT NULL,
  "confirmed_at" timestamptz NOT NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  CONSTRAINT "pk_payment_confirmations" PRIMARY KEY ("payment_confirmation_id")
);;

