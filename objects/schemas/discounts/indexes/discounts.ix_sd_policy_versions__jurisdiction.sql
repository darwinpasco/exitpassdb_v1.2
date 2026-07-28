-- Create index "ix_sd_policy_versions__jurisdiction"
CREATE INDEX "ix_sd_policy_versions__jurisdiction" ON "discounts"."statutory_discount_policy_versions" ("jurisdiction_id", "jurisdiction_code");;
