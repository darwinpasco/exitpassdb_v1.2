-- Create "settlement_comparison_records" table
CREATE TABLE "reconciliation"."settlement_comparison_records" (
  "settlement_comparison_record_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "reconciliation_item_id" uuid NOT NULL,
  "mops_transaction_record_id" uuid NULL,
  "reconciliation_exception_id" uuid NULL,
  "payment_confirmation_id" uuid NULL,
  "provider_outcome_id" uuid NULL,
  "comparison_source_type" "reconciliation"."settlement_comparison_source_type_enum" NOT NULL,
  "comparison_source_ref" character varying(128) NULL,
  "currency_code" character(3) NOT NULL,
  "expected_amount" numeric(18,2) NOT NULL,
  "actual_amount" numeric(18,2) NOT NULL,
  "variance_amount" numeric(18,2) NOT NULL,
  "comparison_result" "reconciliation"."settlement_comparison_result_enum" NOT NULL,
  "mismatch_reason_code" character varying(64) NULL,
  "evidence_ref" character varying(256) NULL,
  "evidence_hash" character(64) NULL,
  "compared_at" timestamptz NOT NULL,
  "compared_by_user_id" uuid NULL,
  "compared_by_service_identity_id" uuid NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  CONSTRAINT "pk_settlement_comparison_records" PRIMARY KEY ("settlement_comparison_record_id")
);;

