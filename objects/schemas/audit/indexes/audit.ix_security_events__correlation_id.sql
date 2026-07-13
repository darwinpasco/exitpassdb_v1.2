-- Create index "ix_security_events__correlation_id" to table: "security_events"
CREATE INDEX "ix_security_events__correlation_id" ON "audit"."security_events" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

