-- Set comment to column: "row_version" on table: "payment_rails"
COMMENT ON COLUMN "payments"."payment_rails"."row_version" IS 'Optimistic concurrency version.';;

