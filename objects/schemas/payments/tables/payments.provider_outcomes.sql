-- Create "provider_outcomes" table
CREATE TABLE "payments"."provider_outcomes" (
  "provider_outcome_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "payment_attempt_id" uuid NOT NULL,
  "provider_session_id" uuid NULL,
  "provider_callback_id" uuid NULL,
  "provider_status_query_id" uuid NULL,
  "payment_rail_id" uuid NOT NULL,
  "provider_transaction_ref" character varying(128) NULL,
  "provider_outcome_status" "payments"."provider_outcome_status_enum" NOT NULL,
  "provider_native_status" character varying(64) NULL,
  "currency_code" character(3) NOT NULL,
  "amount" numeric(18,2) NOT NULL,
  "verified_at" timestamptz NOT NULL,
  "reported_to_central_pms_at" timestamptz NULL,
  "central_pms_report_status" "payments"."central_pms_report_status_enum" NOT NULL,
  "failure_reason_code" character varying(64) NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_provider_outcomes" PRIMARY KEY ("provider_outcome_id")
);;

