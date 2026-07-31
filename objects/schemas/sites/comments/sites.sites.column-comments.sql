-- Set comment to column: "site_id" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."site_id" IS 'Canonical identifier of the site.';;

COMMENT ON COLUMN "sites"."sites"."local_government_unit_id" IS 'Authoritative city or municipality LGU reference for jurisdiction-based statutory parking policy resolution. Legacy city/province/lgu_code remain compatibility fields.';;
