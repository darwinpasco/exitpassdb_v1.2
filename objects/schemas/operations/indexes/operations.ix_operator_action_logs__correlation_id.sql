-- Create index "ix_operator_action_logs__correlation_id" to table: "operator_action_logs"
CREATE INDEX "ix_operator_action_logs__correlation_id" ON "operations"."operator_action_logs" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

