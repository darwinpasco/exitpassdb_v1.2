-- Set comment to column: "routing_key" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."routing_key" IS 'Broker routing key or topic name.';;

