-- Create index "ix_provider_status_queries__correlation_id" to table: "provider_status_queries"
CREATE INDEX "ix_provider_status_queries__correlation_id" ON "payments"."provider_status_queries" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

