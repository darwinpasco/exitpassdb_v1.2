-- Create "provider_callbacks" table
CREATE TABLE "payments"."provider_callbacks" (
  "provider_callback_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "payment_rail_id" uuid NOT NULL,
  "provider_session_id" uuid NULL,
  "payment_attempt_id" uuid NULL,
  "provider_event_ref" character varying(128) NULL,
  "provider_transaction_ref" character varying(128) NULL,
  "callback_type" character varying(64) NOT NULL,
  "payload_hash" character(64) NOT NULL,
  "payload_storage_ref" character varying(256) NULL,
  "headers_hash" character(64) NULL,
  "signature_valid" boolean NULL,
  "timestamp_valid" boolean NULL,
  "source_valid" boolean NULL,
  "verification_status" "payments"."provider_callback_verification_status_enum" NOT NULL,
  "processing_status" "payments"."provider_callback_processing_status_enum" NOT NULL,
  "received_at" timestamptz NOT NULL,
  "processed_at" timestamptz NULL,
  "failure_reason_code" character varying(64) NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  CONSTRAINT "pk_provider_callbacks" PRIMARY KEY ("provider_callback_id")
);;

