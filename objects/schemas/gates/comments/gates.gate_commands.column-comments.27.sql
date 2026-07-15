-- Set comment to column: "last_failure_code" on table: "gate_commands"
COMMENT ON COLUMN "gates"."gate_commands"."last_failure_code" IS 'Most recent failure code retained for retry and terminal failure audit.';;
