-- Create index "ix_audit_trail_entries__created_by_service_identity_id" to table: "audit_trail_entries"
CREATE INDEX "ix_audit_trail_entries__created_by_service_identity_id" ON "audit"."audit_trail_entries" ("created_by_service_identity_id");;

