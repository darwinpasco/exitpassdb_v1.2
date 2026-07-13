-- Create index "ix_provider_sessions__payment_attempt_id" to table: "provider_sessions"
CREATE INDEX "ix_provider_sessions__payment_attempt_id" ON "payments"."provider_sessions" ("payment_attempt_id");;

