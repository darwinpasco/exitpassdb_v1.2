-- Create index "ix_sd_policy_registry__correlation_id" to table: "statutory_discount_policy_registry"
CREATE INDEX "ix_sd_policy_registry__correlation_id" ON "discounts"."statutory_discount_policy_registry" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

