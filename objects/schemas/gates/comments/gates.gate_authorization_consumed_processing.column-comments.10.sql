-- Set comment to column: "gate_device_id" on table: "gate_authorization_consumed_processing"
COMMENT ON COLUMN "gates"."gate_authorization_consumed_processing"."gate_device_id" IS 'Gate device context copied from the consumption handoff, when available.';;
