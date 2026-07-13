-- Set comment to column: "updated_by_service_identity_id" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."updated_by_service_identity_id" IS 'Service identity that last updated the dead-letter record.';;

