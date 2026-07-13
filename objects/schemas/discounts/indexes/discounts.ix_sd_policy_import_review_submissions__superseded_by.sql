-- Create index "ix_sd_policy_import_review_submissions__superseded_by" to table: "statutory_discount_policy_import_review_submissions"
CREATE INDEX "ix_sd_policy_import_review_submissions__superseded_by" ON "discounts"."statutory_discount_policy_import_review_submissions" ("superseded_by_review_submission_id") WHERE (superseded_by_review_submission_id IS NOT NULL);;

