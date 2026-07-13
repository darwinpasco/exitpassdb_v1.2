-- Create index "ix_sd_policy_import_review_submissions__submitted_at" to table: "statutory_discount_policy_import_review_submissions"
CREATE INDEX "ix_sd_policy_import_review_submissions__submitted_at" ON "discounts"."statutory_discount_policy_import_review_submissions" ("submitted_at") WHERE (submitted_at IS NOT NULL);;

