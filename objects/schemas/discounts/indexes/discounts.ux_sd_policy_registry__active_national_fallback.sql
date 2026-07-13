-- Create index "ux_sd_policy_registry__active_national_fallback" to table: "statutory_discount_policy_registry"
CREATE UNIQUE INDEX "ux_sd_policy_registry__active_national_fallback" ON "discounts"."statutory_discount_policy_registry" ("entitlement_type") WHERE ((policy_status = 'ACTIVE'::discounts.discount_policy_status_enum) AND (verification_status = 'ACTIVE_APPROVED'::discounts.policy_verification_status_enum) AND (policy_resolution_basis = 'NATIONAL_LAW_FALLBACK'::discounts.policy_resolution_basis_enum));;

