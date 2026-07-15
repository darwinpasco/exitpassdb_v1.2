-- Set comment to column: "correlation_id" on table: "gate_commands"
COMMENT ON COLUMN "gates"."gate_commands"."correlation_id" IS 'Cross-service correlation identifier carried by the command lifecycle.';;
