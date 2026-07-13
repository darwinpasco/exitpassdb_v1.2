-- Create index "ix_provider_callbacks__correlation_id" to table: "provider_callbacks"
CREATE INDEX "ix_provider_callbacks__correlation_id" ON "payments"."provider_callbacks" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

