-- Create index "ix_sd_policy_registry__jurisdiction_id" to table: "statutory_discount_policy_registry"
CREATE INDEX "ix_sd_policy_registry__jurisdiction_id" ON "discounts"."statutory_discount_policy_registry" ("jurisdiction_id") WHERE (jurisdiction_id IS NOT NULL);;

