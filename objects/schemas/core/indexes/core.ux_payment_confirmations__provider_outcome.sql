-- Create index "ux_payment_confirmations__provider_outcome" to table: "payment_confirmations"
CREATE UNIQUE INDEX "ux_payment_confirmations__provider_outcome" ON "core"."payment_confirmations" ("provider_outcome_id") WHERE (provider_outcome_id IS NOT NULL);;

