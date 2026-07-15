-- Set comment to column: "gate_authorization_consumption_id" on table: "gate_authorization_consumed_processing"
COMMENT ON COLUMN "gates"."gate_authorization_consumed_processing"."gate_authorization_consumption_id" IS 'Canonical gate authorization consumption row that must exist before processing begins.';;
