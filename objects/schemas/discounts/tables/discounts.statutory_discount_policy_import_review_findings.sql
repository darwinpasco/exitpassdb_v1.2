-- Create "statutory_discount_policy_import_review_findings" table
CREATE TABLE "discounts"."statutory_discount_policy_import_review_findings" (
  "review_finding_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "review_submission_id" uuid NOT NULL,
  "row_number" integer NULL,
  "policy_code" character varying(128) NULL,
  "entitlement_type" character varying(64) NULL,
  "decision" "discounts"."policy_import_review_row_decision_enum" NULL,
  "severity" "discounts"."policy_import_review_finding_severity_enum" NOT NULL,
  "finding_code" character varying(96) NOT NULL,
  "field_name" character varying(96) NULL,
  "message" text NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT "pk_sd_policy_import_review_findings" PRIMARY KEY ("review_finding_id"),
  CONSTRAINT "ck_sd_policy_import_review_findings__row_number_positive" CHECK (((row_number IS NULL) OR (row_number > 0))),
  CONSTRAINT "ck_sd_policy_import_review_findings__code_required" CHECK ((btrim((finding_code)::text) <> ''::text)),
  CONSTRAINT "ck_sd_policy_import_review_findings__message_required" CHECK ((btrim(message) <> ''::text))
);;

