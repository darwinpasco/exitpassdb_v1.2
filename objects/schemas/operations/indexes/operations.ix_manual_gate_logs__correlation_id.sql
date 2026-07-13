-- Create index "ix_manual_gate_logs__correlation_id" to table: "manual_gate_logs"
CREATE INDEX "ix_manual_gate_logs__correlation_id" ON "operations"."manual_gate_logs" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

