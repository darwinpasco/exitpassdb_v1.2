-- Create index "ix_sd_policy_registry__supersedes_policy_id" to table: "statutory_discount_policy_registry"
CREATE INDEX "ix_sd_policy_registry__supersedes_policy_id" ON "discounts"."statutory_discount_policy_registry" ("supersedes_policy_id") WHERE (supersedes_policy_id IS NOT NULL);;

