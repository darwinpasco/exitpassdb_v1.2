-- Set comment to column: "service_identity_id" on table: "gate_authorization_consumed_processing"
COMMENT ON COLUMN "gates"."gate_authorization_consumed_processing"."service_identity_id" IS 'Service identity context associated with the consumed authorization handoff, when available.';;
