-- Create index "ix_provider_sessions__correlation_id" to table: "provider_sessions"
CREATE INDEX "ix_provider_sessions__correlation_id" ON "payments"."provider_sessions" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

