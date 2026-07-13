-- Create index "ix_integration_health_records__correlation_id" to table: "integration_health_records"
CREATE INDEX "ix_integration_health_records__correlation_id" ON "integration"."integration_health_records" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

