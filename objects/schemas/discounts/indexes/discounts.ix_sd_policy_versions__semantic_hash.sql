-- Create index "ix_sd_policy_versions__semantic_hash"
CREATE INDEX "ix_sd_policy_versions__semantic_hash" ON "discounts"."statutory_discount_policy_versions" ("policy_semantic_hash");;
