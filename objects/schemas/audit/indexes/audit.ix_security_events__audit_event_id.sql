-- Create index "ix_security_events__audit_event_id" to table: "security_events"
CREATE INDEX "ix_security_events__audit_event_id" ON "audit"."security_events" ("audit_event_id");;

