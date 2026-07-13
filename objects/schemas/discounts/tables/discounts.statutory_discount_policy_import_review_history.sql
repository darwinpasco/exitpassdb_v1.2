-- Create "statutory_discount_policy_import_review_history" table
CREATE TABLE "discounts"."statutory_discount_policy_import_review_history" (
  "review_history_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "review_submission_id" uuid NOT NULL,
  "event_type" character varying(64) NOT NULL,
  "event_summary" text NOT NULL,
  "actor_operator_user_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "correlation_id" uuid NULL,
  "event_payload_json" jsonb NULL,
  CONSTRAINT "pk_sd_policy_import_review_history" PRIMARY KEY ("review_history_id"),
  CONSTRAINT "ck_sd_policy_import_review_history__event_type_required" CHECK ((btrim((event_type)::text) <> ''::text)),
  CONSTRAINT "ck_sd_policy_import_review_history__event_summary_required" CHECK ((btrim(event_summary) <> ''::text)),
  CONSTRAINT "ck_sd_policy_import_review_history__payload_object" CHECK (((event_payload_json IS NULL) OR (jsonb_typeof(event_payload_json) = 'object'::text)))
);;

