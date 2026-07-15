-- Set comment to column: "processing_key" on table: "gate_authorization_consumed_processing"
COMMENT ON COLUMN "gates"."gate_authorization_consumed_processing"."processing_key" IS 'Source processing key used with event type for idempotent handoff processing.';;
