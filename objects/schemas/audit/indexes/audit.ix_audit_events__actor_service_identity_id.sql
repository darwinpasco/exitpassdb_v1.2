-- Create index "ix_audit_events__actor_service_identity_id" to table: "audit_events"
CREATE INDEX "ix_audit_events__actor_service_identity_id" ON "audit"."audit_events" ("actor_service_identity_id");;

