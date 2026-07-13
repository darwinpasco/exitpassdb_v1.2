-- Set comment to column: "row_version" on table: "payment_attempts"
COMMENT ON COLUMN "core"."payment_attempts"."row_version" IS 'Optimistic concurrency version.';;

