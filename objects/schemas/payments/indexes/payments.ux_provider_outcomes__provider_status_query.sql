-- Create index "ux_provider_outcomes__provider_status_query" to table: "provider_outcomes"
CREATE UNIQUE INDEX "ux_provider_outcomes__provider_status_query" ON "payments"."provider_outcomes" ("provider_status_query_id") WHERE (provider_status_query_id IS NOT NULL);;

