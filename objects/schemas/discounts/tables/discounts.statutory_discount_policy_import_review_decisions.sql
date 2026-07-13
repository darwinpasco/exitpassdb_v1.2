-- Create "statutory_discount_policy_import_review_decisions" table
CREATE TABLE "discounts"."statutory_discount_policy_import_review_decisions" (
  "review_decision_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "review_submission_id" uuid NOT NULL,
  "reviewer_operator_user_id" uuid NOT NULL,
  "reviewer_role" "discounts"."policy_import_review_role_enum" NOT NULL,
  "decision_action" "discounts"."policy_import_review_action_enum" NOT NULL,
  "decision_status_from" "discounts"."policy_import_review_status_enum" NULL,
  "decision_status_to" "discounts"."policy_import_review_status_enum" NULL,
  "decision_reason" text NULL,
  "decision_notes" text NULL,
  "decided_at" timestamptz NOT NULL DEFAULT now(),
  "correlation_id" uuid NULL,
  CONSTRAINT "pk_sd_policy_import_review_decisions" PRIMARY KEY ("review_decision_id"),
  CONSTRAINT "ck_sd_policy_import_review_decisions__reason_required" CHECK (((decision_action <> ALL (ARRAY['REJECT'::discounts.policy_import_review_action_enum, 'REQUEST_CHANGES'::discounts.policy_import_review_action_enum])) OR (btrim(COALESCE(decision_reason, ''::text)) <> ''::text)))
);;

