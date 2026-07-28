-- Create index "ix_sd_decision_policy_authorities__jurisdiction"
CREATE INDEX "ix_sd_decision_policy_authorities__jurisdiction" ON "discounts"."statutory_discount_decision_policy_authorities" ("jurisdiction_id", "entitlement_type");;
