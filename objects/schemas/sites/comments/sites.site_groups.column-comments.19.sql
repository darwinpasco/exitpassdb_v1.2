-- Set comment to column: "row_version" on table: "site_groups"
COMMENT ON COLUMN "sites"."site_groups"."row_version" IS 'Optimistic concurrency version.';;

