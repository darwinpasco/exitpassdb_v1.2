-- Set comment to column: "resolved_by_user_id" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."resolved_by_user_id" IS 'User who resolved dead-letter record.';;

