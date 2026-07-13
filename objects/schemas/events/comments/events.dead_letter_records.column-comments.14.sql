-- Set comment to column: "replay_requested_at" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."replay_requested_at" IS 'Timestamp when replay was requested.';;

