-- Set comment to column: "processing_status" on table: "gate_authorization_consumed_processing"
COMMENT ON COLUMN "gates"."gate_authorization_consumed_processing"."processing_status" IS 'Processing lifecycle status: PROCESSING, PROCESSED, or FAILED.';;
