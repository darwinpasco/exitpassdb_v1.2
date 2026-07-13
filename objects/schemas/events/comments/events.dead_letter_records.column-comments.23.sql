-- Set comment to column: "row_version" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."row_version" IS 'Optimistic concurrency version.';;

