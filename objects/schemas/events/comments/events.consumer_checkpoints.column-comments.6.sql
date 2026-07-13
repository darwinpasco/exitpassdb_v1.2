-- Set comment to column: "last_outbox_event_id" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."last_outbox_event_id" IS 'Last processed outbox event.';;

