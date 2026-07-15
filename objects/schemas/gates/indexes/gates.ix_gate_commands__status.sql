-- Create index "ix_gate_commands__status" to table: "gate_commands"
CREATE INDEX "ix_gate_commands__status" ON "gates"."gate_commands" ("command_status");;
