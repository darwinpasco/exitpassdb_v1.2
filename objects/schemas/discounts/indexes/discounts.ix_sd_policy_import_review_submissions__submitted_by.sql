-- Create index "ix_sd_policy_import_review_submissions__submitted_by" to table: "statutory_discount_policy_import_review_submissions"
CREATE INDEX "ix_sd_policy_import_review_submissions__submitted_by" ON "discounts"."statutory_discount_policy_import_review_submissions" ("submitted_by_operator_user_id") WHERE (submitted_by_operator_user_id IS NOT NULL);;

