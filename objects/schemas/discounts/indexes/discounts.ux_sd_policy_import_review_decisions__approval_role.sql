-- Create index "ux_sd_policy_import_review_decisions__approval_role" to table: "statutory_discount_policy_import_review_decisions"
CREATE UNIQUE INDEX "ux_sd_policy_import_review_decisions__approval_role" ON "discounts"."statutory_discount_policy_import_review_decisions" ("review_submission_id", "reviewer_role") WHERE (decision_action = ANY (ARRAY['APPROVE_LEGAL'::discounts.policy_import_review_action_enum, 'APPROVE_OPS'::discounts.policy_import_review_action_enum, 'APPROVE_QA'::discounts.policy_import_review_action_enum, 'APPROVE_DB'::discounts.policy_import_review_action_enum]));;

