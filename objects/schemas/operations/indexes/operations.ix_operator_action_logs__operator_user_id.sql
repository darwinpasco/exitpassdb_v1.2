-- Create index "ix_operator_action_logs__operator_user_id" to table: "operator_action_logs"
CREATE INDEX "ix_operator_action_logs__operator_user_id" ON "operations"."operator_action_logs" ("operator_user_id");;

