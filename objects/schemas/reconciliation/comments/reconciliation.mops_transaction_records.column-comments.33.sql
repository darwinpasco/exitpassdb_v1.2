-- Set comment to column: "row_version" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."row_version" IS 'Optimistic concurrency version.';;

