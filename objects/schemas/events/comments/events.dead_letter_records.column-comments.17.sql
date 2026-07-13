-- Set comment to column: "correlation_id" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."correlation_id" IS 'Cross-service correlation identifier.';;

