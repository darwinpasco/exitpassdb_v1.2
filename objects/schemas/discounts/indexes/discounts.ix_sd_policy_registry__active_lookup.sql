-- Create index "ix_sd_policy_registry__active_lookup" to table: "statutory_discount_policy_registry"
CREATE INDEX "ix_sd_policy_registry__active_lookup" ON "discounts"."statutory_discount_policy_registry" ("entitlement_type", "policy_status", "verification_status", "policy_resolution_basis", "jurisdiction_code", "site_group_id", "site_id", "effective_from", "effective_to");;

