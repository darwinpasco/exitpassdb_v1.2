-- Set comment to column: "replay_requested_by_service_identity_id" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."replay_requested_by_service_identity_id" IS 'Service identity that requested replay.';;

