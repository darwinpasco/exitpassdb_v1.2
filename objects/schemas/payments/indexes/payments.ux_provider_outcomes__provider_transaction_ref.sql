-- Create index "ux_provider_outcomes__provider_transaction_ref" to table: "provider_outcomes"
CREATE UNIQUE INDEX "ux_provider_outcomes__provider_transaction_ref" ON "payments"."provider_outcomes" ("payment_rail_id", "provider_transaction_ref") WHERE (provider_transaction_ref IS NOT NULL);;

