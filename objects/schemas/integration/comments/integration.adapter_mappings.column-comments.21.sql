-- Set comment to column: "row_version" on table: "adapter_mappings"
COMMENT ON COLUMN "integration"."adapter_mappings"."row_version" IS 'Optimistic concurrency version.';;

