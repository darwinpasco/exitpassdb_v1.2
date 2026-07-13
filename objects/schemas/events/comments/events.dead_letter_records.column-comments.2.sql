-- Set comment to column: "event_publication_id" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."event_publication_id" IS 'Publication attempt that caused dead-lettering, where applicable.';;

