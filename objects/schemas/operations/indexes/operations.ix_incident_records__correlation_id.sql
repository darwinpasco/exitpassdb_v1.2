-- Create index "ix_incident_records__correlation_id" to table: "incident_records"
CREATE INDEX "ix_incident_records__correlation_id" ON "operations"."incident_records" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

