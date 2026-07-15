-- Create index "ix_gate_commands__consumption" to table: "gate_commands"
CREATE INDEX "ix_gate_commands__consumption" ON "gates"."gate_commands" ("gate_authorization_consumption_id");;
