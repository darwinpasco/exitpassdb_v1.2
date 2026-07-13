-- Create index "ix_security_events__resolved_by_user_id" to table: "security_events"
CREATE INDEX "ix_security_events__resolved_by_user_id" ON "audit"."security_events" ("resolved_by_user_id");;

