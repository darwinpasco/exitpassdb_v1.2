-- Create index "ix_gate_auth_consumed_processing__status" to table: "gate_authorization_consumed_processing"
CREATE INDEX "ix_gate_auth_consumed_processing__status" ON "gates"."gate_authorization_consumed_processing" ("processing_status");;
