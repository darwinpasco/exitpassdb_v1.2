-- Create index "ix_gate_auth_consumed_processing__correlation_id" to table: "gate_authorization_consumed_processing"
CREATE INDEX "ix_gate_auth_consumed_processing__correlation_id" ON "gates"."gate_authorization_consumed_processing" ("correlation_id");;
