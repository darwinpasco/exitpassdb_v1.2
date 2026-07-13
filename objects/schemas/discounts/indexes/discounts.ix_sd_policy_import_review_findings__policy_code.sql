-- Create index "ix_sd_policy_import_review_findings__policy_code" to table: "statutory_discount_policy_import_review_findings"
CREATE INDEX "ix_sd_policy_import_review_findings__policy_code" ON "discounts"."statutory_discount_policy_import_review_findings" ("policy_code") WHERE (policy_code IS NOT NULL);;

