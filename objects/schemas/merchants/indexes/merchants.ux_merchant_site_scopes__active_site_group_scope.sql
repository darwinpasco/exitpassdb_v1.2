-- Create index "ux_merchant_site_scopes__active_site_group_scope" to table: "merchant_site_scopes"
CREATE UNIQUE INDEX "ux_merchant_site_scopes__active_site_group_scope" ON "merchants"."merchant_site_scopes" ("merchant_id", "site_group_id", "scope_type") WHERE ((scope_status = 'ACTIVE'::merchants.merchant_site_scope_status_enum) AND (site_group_id IS NOT NULL) AND (site_id IS NULL));;

