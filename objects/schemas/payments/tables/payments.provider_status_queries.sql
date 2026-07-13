-- Create "provider_status_queries" table
CREATE TABLE "payments"."provider_status_queries" (
  "provider_status_query_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "payment_attempt_id" uuid NOT NULL,
  "provider_session_id" uuid NULL,
  "payment_rail_id" uuid NOT NULL,
  "provider_transaction_ref" character varying(128) NULL,
  "query_status" "payments"."provider_status_query_status_enum" NOT NULL,
  "provider_result_status" character varying(64) NULL,
  "http_status_code" integer NULL,
  "request_hash" character(64) NULL,
  "response_hash" character(64) NULL,
  "response_storage_ref" character varying(256) NULL,
  "failure_reason_code" character varying(64) NULL,
  "requested_at" timestamptz NOT NULL,
  "completed_at" timestamptz NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  CONSTRAINT "pk_provider_status_queries" PRIMARY KEY ("provider_status_query_id")
);;

