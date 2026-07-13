-- Create index "ix_gate_events__correlation_id" to table: "gate_events"
CREATE INDEX "ix_gate_events__correlation_id" ON "gates"."gate_events" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

