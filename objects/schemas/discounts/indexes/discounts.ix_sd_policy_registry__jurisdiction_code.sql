-- Create index "ix_sd_policy_registry__jurisdiction_code" to table: "statutory_discount_policy_registry"
CREATE INDEX "ix_sd_policy_registry__jurisdiction_code" ON "discounts"."statutory_discount_policy_registry" ("jurisdiction_code") WHERE (jurisdiction_code IS NOT NULL);;

