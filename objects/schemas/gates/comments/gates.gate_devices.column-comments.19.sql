-- Set comment to column: "row_version" on table: "gate_devices"
COMMENT ON COLUMN "gates"."gate_devices"."row_version" IS 'Optimistic concurrency version.';;

