-- Set comment to column: "completed_at" on table: "gate_commands"
COMMENT ON COLUMN "gates"."gate_commands"."completed_at" IS 'Timestamp when a terminal or retryable attempt result was recorded.';;
