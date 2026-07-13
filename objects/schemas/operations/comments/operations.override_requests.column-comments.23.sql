-- Set comment to column: "row_version" on table: "override_requests"
COMMENT ON COLUMN "operations"."override_requests"."row_version" IS 'Optimistic concurrency version.';;

