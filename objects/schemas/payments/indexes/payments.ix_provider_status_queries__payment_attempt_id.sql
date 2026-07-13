-- Create index "ix_provider_status_queries__payment_attempt_id" to table: "provider_status_queries"
CREATE INDEX "ix_provider_status_queries__payment_attempt_id" ON "payments"."provider_status_queries" ("payment_attempt_id");;

