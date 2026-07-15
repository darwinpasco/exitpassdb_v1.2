-- Set comment to column: "last_attempted_at" on table: "gate_authorization_consumed_processing"
COMMENT ON COLUMN "gates"."gate_authorization_consumed_processing"."last_attempted_at" IS 'Timestamp when processing was most recently attempted, when different from first attempt.';;
