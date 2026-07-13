-- Create index "ix_audit_trail_entries__correlation_id" to table: "audit_trail_entries"
CREATE INDEX "ix_audit_trail_entries__correlation_id" ON "audit"."audit_trail_entries" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

