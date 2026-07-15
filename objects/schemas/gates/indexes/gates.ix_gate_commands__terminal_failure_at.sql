-- Create index "ix_gate_commands__terminal_failure_at" to table: "gate_commands"
CREATE INDEX "ix_gate_commands__terminal_failure_at" ON "gates"."gate_commands" ("terminal_failure_at") WHERE ("command_status" = 'TERMINAL_FAILURE');;
