-- Set comment to column: "service_identity_id" on table: "gate_commands"
COMMENT ON COLUMN "gates"."gate_commands"."service_identity_id" IS 'Service identity context associated with the command source, when available.';;
