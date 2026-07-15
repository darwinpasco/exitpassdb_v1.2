-- Set comment to column: "command_status" on table: "gate_commands"
COMMENT ON COLUMN "gates"."gate_commands"."command_status" IS 'Command lifecycle status: REQUESTED, IN_PROGRESS, SUCCEEDED, FAILED, RETRYABLE, or TERMINAL_FAILURE.';;
