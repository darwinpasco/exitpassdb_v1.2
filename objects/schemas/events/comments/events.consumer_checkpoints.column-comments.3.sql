-- Set comment to column: "subscription_name" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."subscription_name" IS 'Queue, subscription, topic, or routing subscription name.';;

