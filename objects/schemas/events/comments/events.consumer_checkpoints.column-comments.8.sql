-- Set comment to column: "last_broker_offset" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."last_broker_offset" IS 'Broker offset, delivery tag, sequence, or cursor.';;

