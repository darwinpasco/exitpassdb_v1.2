-- Set comment to column: "row_version" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."row_version" IS 'Optimistic concurrency version.';;

