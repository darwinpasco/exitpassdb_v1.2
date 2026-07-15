-- Set comment to column: "gate_device_id" on table: "gate_commands"
COMMENT ON COLUMN "gates"."gate_commands"."gate_device_id" IS 'Gate device context for command routing, when available.';;
