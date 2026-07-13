-- Create index "ix_audit_events__causation_id" to table: "audit_events"
CREATE INDEX "ix_audit_events__causation_id" ON "audit"."audit_events" ("causation_id") WHERE (causation_id IS NOT NULL);;

