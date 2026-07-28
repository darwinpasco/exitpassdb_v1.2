-- Create index "ix_sd_policy_version_relationships__target"
CREATE INDEX "ix_sd_policy_version_relationships__target" ON "discounts"."statutory_discount_policy_version_relationships" ("target_policy_version_id", "relationship_type");;
