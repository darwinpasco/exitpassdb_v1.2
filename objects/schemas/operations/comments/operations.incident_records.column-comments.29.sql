-- Set comment to column: "row_version" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."row_version" IS 'Optimistic concurrency version.';;

