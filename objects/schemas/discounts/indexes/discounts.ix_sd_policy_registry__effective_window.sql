-- Create index "ix_sd_policy_registry__effective_window" to table: "statutory_discount_policy_registry"
CREATE INDEX "ix_sd_policy_registry__effective_window" ON "discounts"."statutory_discount_policy_registry" ("effective_from", "effective_to");;

