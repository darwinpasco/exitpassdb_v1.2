-- Create index "ix_sd_policy_import_review_submissions__source_file_sha256" to table: "statutory_discount_policy_import_review_submissions"
CREATE INDEX "ix_sd_policy_import_review_submissions__source_file_sha256" ON "discounts"."statutory_discount_policy_import_review_submissions" ("source_file_sha256") WHERE (source_file_sha256 IS NOT NULL);;

