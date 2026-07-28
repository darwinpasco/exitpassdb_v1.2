-- Create index "ix_sd_policy_versions__supersession"
CREATE INDEX "ix_sd_policy_versions__supersession" ON "discounts"."statutory_discount_policy_versions" ("supersedes_policy_version_id", "superseded_by_policy_version_id");;
