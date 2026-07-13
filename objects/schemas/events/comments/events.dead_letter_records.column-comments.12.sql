-- Set comment to column: "resolved_by_service_identity_id" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."resolved_by_service_identity_id" IS 'Service identity that resolved dead-letter record.';;

