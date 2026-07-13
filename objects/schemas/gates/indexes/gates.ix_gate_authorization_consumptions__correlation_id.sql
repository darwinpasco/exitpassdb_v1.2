-- Create index "ix_gate_authorization_consumptions__correlation_id" to table: "gate_authorization_consumptions"
CREATE INDEX "ix_gate_authorization_consumptions__correlation_id" ON "gates"."gate_authorization_consumptions" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

