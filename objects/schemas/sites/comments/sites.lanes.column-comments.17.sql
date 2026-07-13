-- Set comment to column: "row_version" on table: "lanes"
COMMENT ON COLUMN "sites"."lanes"."row_version" IS 'Optimistic concurrency version.';;

