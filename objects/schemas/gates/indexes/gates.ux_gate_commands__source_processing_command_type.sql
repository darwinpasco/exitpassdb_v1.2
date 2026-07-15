-- Create index "ux_gate_commands__source_processing_command_type" to table: "gate_commands"
CREATE UNIQUE INDEX "ux_gate_commands__source_processing_command_type" ON "gates"."gate_commands" ("source_processing_id", "command_type");;
