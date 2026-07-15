-- Set comment to column: "next_attempt_at" on table: "gate_commands"
COMMENT ON COLUMN "gates"."gate_commands"."next_attempt_at" IS 'Timestamp when a retryable command is next eligible for another attempt.';;
