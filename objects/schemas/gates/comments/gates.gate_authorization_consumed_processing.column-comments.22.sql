-- Set comment to column: "processed_at" on table: "gate_authorization_consumed_processing"
COMMENT ON COLUMN "gates"."gate_authorization_consumed_processing"."processed_at" IS 'Timestamp when processing completed successfully; required only for PROCESSED rows.';;
