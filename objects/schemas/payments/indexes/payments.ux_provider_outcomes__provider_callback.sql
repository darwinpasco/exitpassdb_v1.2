-- Create index "ux_provider_outcomes__provider_callback" to table: "provider_outcomes"
CREATE UNIQUE INDEX "ux_provider_outcomes__provider_callback" ON "payments"."provider_outcomes" ("provider_callback_id") WHERE (provider_callback_id IS NOT NULL);;

