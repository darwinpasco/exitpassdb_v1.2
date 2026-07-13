-- Create index "ix_sd_policy_registry__superseded_by_policy_id" to table: "statutory_discount_policy_registry"
CREATE INDEX "ix_sd_policy_registry__superseded_by_policy_id" ON "discounts"."statutory_discount_policy_registry" ("superseded_by_policy_id") WHERE (superseded_by_policy_id IS NOT NULL);;

