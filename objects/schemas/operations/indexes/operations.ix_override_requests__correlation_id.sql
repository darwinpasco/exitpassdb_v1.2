-- Create index "ix_override_requests__correlation_id" to table: "override_requests"
CREATE INDEX "ix_override_requests__correlation_id" ON "operations"."override_requests" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

