-- Set comment to column: "source_event_ref" on table: "gate_commands"
COMMENT ON COLUMN "gates"."gate_commands"."source_event_ref" IS 'Optional source event reference copied from the handoff for audit and troubleshooting.';;
