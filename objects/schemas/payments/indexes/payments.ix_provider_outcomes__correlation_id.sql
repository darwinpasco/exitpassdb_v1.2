-- Create index "ix_provider_outcomes__correlation_id" to table: "provider_outcomes"
CREATE INDEX "ix_provider_outcomes__correlation_id" ON "payments"."provider_outcomes" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

