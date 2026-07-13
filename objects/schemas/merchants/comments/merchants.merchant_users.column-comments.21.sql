-- Set comment to column: "row_version" on table: "merchant_users"
COMMENT ON COLUMN "merchants"."merchant_users"."row_version" IS 'Optimistic concurrency version.';;

