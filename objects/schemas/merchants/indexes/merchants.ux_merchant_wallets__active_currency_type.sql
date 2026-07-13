-- Create index "ux_merchant_wallets__active_currency_type" to table: "merchant_wallets"
CREATE UNIQUE INDEX "ux_merchant_wallets__active_currency_type" ON "merchants"."merchant_wallets" ("merchant_id", "currency_code", "wallet_type") WHERE (wallet_status = 'ACTIVE'::merchants.merchant_wallet_status_enum);;

