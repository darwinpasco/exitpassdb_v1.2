-- Create index "ix_exit_authorizations__correlation_id" to table: "exit_authorizations"
CREATE INDEX "ix_exit_authorizations__correlation_id" ON "core"."exit_authorizations" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

