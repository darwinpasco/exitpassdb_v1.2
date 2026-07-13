-- Set comment to column: "row_version" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."row_version" IS 'Optimistic concurrency version.';;

