-- Set comment to column: "last_attempted_at" on table: "gate_commands"
COMMENT ON COLUMN "gates"."gate_commands"."last_attempted_at" IS 'Timestamp when command processing or execution was most recently attempted.';;
