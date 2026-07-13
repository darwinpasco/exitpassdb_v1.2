-- Create index "ix_gate_heartbeats__correlation_id" to table: "gate_heartbeats"
CREATE INDEX "ix_gate_heartbeats__correlation_id" ON "gates"."gate_heartbeats" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

