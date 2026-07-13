-- Create index "ix_security_events__actor_service_identity_id" to table: "security_events"
CREATE INDEX "ix_security_events__actor_service_identity_id" ON "audit"."security_events" ("actor_service_identity_id");;

