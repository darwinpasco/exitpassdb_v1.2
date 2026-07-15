-- Create index "ix_gate_auth_consumed_processing__consumption" to table: "gate_authorization_consumed_processing"
CREATE INDEX "ix_gate_auth_consumed_processing__consumption" ON "gates"."gate_authorization_consumed_processing" ("gate_authorization_consumption_id");;
