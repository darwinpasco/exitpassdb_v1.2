-- Set comment to column: "last_failure_reason" on table: "gate_commands"
COMMENT ON COLUMN "gates"."gate_commands"."last_failure_reason" IS 'Most recent failure reason retained for retry and terminal failure audit.';;
