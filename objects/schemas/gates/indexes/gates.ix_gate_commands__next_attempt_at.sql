-- Create index "ix_gate_commands__next_attempt_at" to table: "gate_commands"
CREATE INDEX "ix_gate_commands__next_attempt_at" ON "gates"."gate_commands" ("next_attempt_at") WHERE ("command_status" = 'RETRYABLE');;
