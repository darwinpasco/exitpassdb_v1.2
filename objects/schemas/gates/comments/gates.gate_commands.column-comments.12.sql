-- Set comment to column: "lane_id" on table: "gate_commands"
COMMENT ON COLUMN "gates"."gate_commands"."lane_id" IS 'Lane context for command routing, when available.';;
