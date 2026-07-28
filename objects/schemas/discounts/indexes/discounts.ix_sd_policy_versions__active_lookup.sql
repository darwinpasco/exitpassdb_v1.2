-- Create index "ix_sd_policy_versions__active_lookup"
CREATE INDEX "ix_sd_policy_versions__active_lookup" ON "discounts"."statutory_discount_policy_versions" ("entitlement_type", "jurisdiction_id", "policy_scope_type", "site_group_id", "site_id", "transaction_publication_status", "parking_service_applicability", "transaction_use_effective_from", "transaction_use_effective_to");;
