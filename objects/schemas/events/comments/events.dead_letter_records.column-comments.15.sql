-- Set comment to column: "replay_requested_by_user_id" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."replay_requested_by_user_id" IS 'User who requested replay.';;

