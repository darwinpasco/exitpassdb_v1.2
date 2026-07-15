-- Set comment to column: "lane_id" on table: "gate_authorization_consumed_processing"
COMMENT ON COLUMN "gates"."gate_authorization_consumed_processing"."lane_id" IS 'Lane context copied from the consumption handoff, when available.';;
