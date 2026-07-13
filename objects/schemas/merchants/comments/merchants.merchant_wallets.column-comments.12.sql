-- Set comment to column: "allows_statutory_discount_funding" on table: "merchant_wallets"
COMMENT ON COLUMN "merchants"."merchant_wallets"."allows_statutory_discount_funding" IS 'Must be false. Merchant wallets must not fund statutory discounts.';;

