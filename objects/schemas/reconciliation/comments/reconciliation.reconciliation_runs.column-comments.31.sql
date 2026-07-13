-- Set comment to column: "row_version" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."row_version" IS 'Optimistic concurrency version.';;

