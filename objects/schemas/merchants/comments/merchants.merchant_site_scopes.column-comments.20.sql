-- Set comment to column: "row_version" on table: "merchant_site_scopes"
COMMENT ON COLUMN "merchants"."merchant_site_scopes"."row_version" IS 'Optimistic concurrency version.';;

