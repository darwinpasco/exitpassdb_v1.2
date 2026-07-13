-- Create index "ix_provider_callbacks__payment_attempt_id" to table: "provider_callbacks"
CREATE INDEX "ix_provider_callbacks__payment_attempt_id" ON "payments"."provider_callbacks" ("payment_attempt_id");;

