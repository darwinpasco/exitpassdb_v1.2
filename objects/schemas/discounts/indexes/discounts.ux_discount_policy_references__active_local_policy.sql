-- Create index "ux_discount_policy_references__active_local_policy" to table: "discount_policy_references"
CREATE UNIQUE INDEX "ux_discount_policy_references__active_local_policy" ON "discounts"."discount_policy_references" ("entitlement_type", "lgu_code", "site_group_id", "site_id", "policy_level", "policy_version") WHERE ((policy_status = 'ACTIVE'::discounts.discount_policy_status_enum) AND (lgu_code IS NOT NULL));;

