-- Create index "ix_sd_decision_policy_authorities__policy_version"
CREATE INDEX "ix_sd_decision_policy_authorities__policy_version" ON "discounts"."statutory_discount_decision_policy_authorities" ("statutory_discount_policy_version_id");;
