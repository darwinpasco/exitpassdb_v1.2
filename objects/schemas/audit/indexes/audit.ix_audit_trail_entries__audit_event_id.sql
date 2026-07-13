-- Create index "ix_audit_trail_entries__audit_event_id" to table: "audit_trail_entries"
CREATE INDEX "ix_audit_trail_entries__audit_event_id" ON "audit"."audit_trail_entries" ("audit_event_id");;

