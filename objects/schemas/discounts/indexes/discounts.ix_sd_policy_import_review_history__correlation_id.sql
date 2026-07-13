-- Create index "ix_sd_policy_import_review_history__correlation_id" to table: "statutory_discount_policy_import_review_history"
CREATE INDEX "ix_sd_policy_import_review_history__correlation_id" ON "discounts"."statutory_discount_policy_import_review_history" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

