-- Set comment to column: "last_domain_event_id" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."last_domain_event_id" IS 'Last processed domain event, where applicable.';;

