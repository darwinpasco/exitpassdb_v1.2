-- Set comment to column: "created_by_service_identity_id" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."created_by_service_identity_id" IS 'Service identity that created the dead-letter record.';;

