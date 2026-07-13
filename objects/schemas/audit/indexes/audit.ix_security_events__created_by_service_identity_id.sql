-- Create index "ix_security_events__created_by_service_identity_id" to table: "security_events"
CREATE INDEX "ix_security_events__created_by_service_identity_id" ON "audit"."security_events" ("created_by_service_identity_id");;

