-- Set comment to column: "row_version" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."row_version" IS 'Optimistic concurrency version.';;

