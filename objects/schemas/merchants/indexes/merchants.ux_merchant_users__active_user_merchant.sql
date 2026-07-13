-- Create index "ux_merchant_users__active_user_merchant" to table: "merchant_users"
CREATE UNIQUE INDEX "ux_merchant_users__active_user_merchant" ON "merchants"."merchant_users" ("merchant_id", "user_id") WHERE (merchant_user_status = 'ACTIVE'::merchants.merchant_user_status_enum);;

