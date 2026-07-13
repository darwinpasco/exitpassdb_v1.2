-- Create "provider_sessions" table
CREATE TABLE "payments"."provider_sessions" (
  "provider_session_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "payment_attempt_id" uuid NOT NULL,
  "payment_rail_id" uuid NOT NULL,
  "provider_session_ref" character varying(128) NULL,
  "provider_transaction_ref" character varying(128) NULL,
  "idempotency_key" character varying(128) NOT NULL,
  "session_status" "payments"."provider_session_status_enum" NOT NULL,
  "currency_code" character(3) NOT NULL,
  "amount" numeric(18,2) NOT NULL,
  "checkout_url" text NULL,
  "qr_payload" text NULL,
  "expires_at" timestamptz NULL,
  "provider_created_at" timestamptz NULL,
  "provider_expires_at" timestamptz NULL,
  "raw_provider_metadata_ref" character varying(128) NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_provider_sessions" PRIMARY KEY ("provider_session_id")
);;

