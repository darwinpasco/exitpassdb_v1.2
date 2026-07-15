-- Set comment to column: "max_attempts" on table: "gate_commands"
COMMENT ON COLUMN "gates"."gate_commands"."max_attempts" IS 'Maximum allowed attempts under the command retry policy.';;
