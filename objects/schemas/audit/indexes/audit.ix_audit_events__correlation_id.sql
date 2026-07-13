-- Create index "ix_audit_events__correlation_id" to table: "audit_events"
CREATE INDEX "ix_audit_events__correlation_id" ON "audit"."audit_events" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

