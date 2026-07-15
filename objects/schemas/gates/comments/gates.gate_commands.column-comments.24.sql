-- Set comment to column: "terminal_failure_at" on table: "gate_commands"
COMMENT ON COLUMN "gates"."gate_commands"."terminal_failure_at" IS 'Timestamp when the command reached terminal failure and must not be retried.';;
