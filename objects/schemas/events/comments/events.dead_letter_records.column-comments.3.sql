-- Set comment to column: "consumer_name" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."consumer_name" IS 'Consumer that dead-lettered the event, where consumer-side dead-lettering is recorded.';;

