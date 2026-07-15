-- Set comment to column: "source_event_id" on table: "gate_commands"
COMMENT ON COLUMN "gates"."gate_commands"."source_event_id" IS 'Optional source integration event identifier copied from the handoff.';;
