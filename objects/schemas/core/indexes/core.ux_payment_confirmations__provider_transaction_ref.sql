-- Create index "ux_payment_confirmations__provider_transaction_ref" to table: "payment_confirmations"
CREATE UNIQUE INDEX "ux_payment_confirmations__provider_transaction_ref" ON "core"."payment_confirmations" ("payment_rail_id", "provider_transaction_ref") WHERE (provider_transaction_ref IS NOT NULL);;

