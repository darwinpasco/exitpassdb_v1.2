-- Set comment to column: "outbox_event_id" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."outbox_event_id" IS 'Outbox event that dead-lettered.';;

