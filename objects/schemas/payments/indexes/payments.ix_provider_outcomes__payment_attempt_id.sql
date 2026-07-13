-- Create index "ix_provider_outcomes__payment_attempt_id" to table: "provider_outcomes"
CREATE INDEX "ix_provider_outcomes__payment_attempt_id" ON "payments"."provider_outcomes" ("payment_attempt_id");;

