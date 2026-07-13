-- Create index "ux_merchant_site_scopes__active_site_scope" to table: "merchant_site_scopes"
CREATE UNIQUE INDEX "ux_merchant_site_scopes__active_site_scope" ON "merchants"."merchant_site_scopes" ("merchant_id", "site_id", "scope_type") WHERE ((scope_status = 'ACTIVE'::merchants.merchant_site_scope_status_enum) AND (site_id IS NOT NULL));;

