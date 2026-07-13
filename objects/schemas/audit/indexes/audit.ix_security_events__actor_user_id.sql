-- Create index "ix_security_events__actor_user_id" to table: "security_events"
CREATE INDEX "ix_security_events__actor_user_id" ON "audit"."security_events" ("actor_user_id");;

