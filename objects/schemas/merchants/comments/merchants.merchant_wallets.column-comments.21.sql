-- Set comment to column: "row_version" on table: "merchant_wallets"
COMMENT ON COLUMN "merchants"."merchant_wallets"."row_version" IS 'Optimistic concurrency version.';;

