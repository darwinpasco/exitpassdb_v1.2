-- Set comment to column: "row_version" on table: "device_assignments"
COMMENT ON COLUMN "sites"."device_assignments"."row_version" IS 'Optimistic concurrency version.';;

