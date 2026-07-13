-- Create index "ix_domain_events__actor_service_identity_id" to table: "domain_events"
CREATE INDEX "ix_domain_events__actor_service_identity_id" ON "events"."domain_events" ("actor_service_identity_id");;

