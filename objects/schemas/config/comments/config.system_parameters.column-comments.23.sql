-- Set comment to column: "row_version" on table: "system_parameters"
COMMENT ON COLUMN "config"."system_parameters"."row_version" IS 'Optimistic concurrency version.';;

