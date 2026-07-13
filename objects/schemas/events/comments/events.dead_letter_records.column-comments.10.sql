-- Set comment to column: "resolved_at" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."resolved_at" IS 'Timestamp when dead-letter was resolved.';;

