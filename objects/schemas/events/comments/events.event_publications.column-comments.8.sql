-- Set comment to column: "broker_message_id" on table: "event_publications"
COMMENT ON COLUMN "events"."event_publications"."broker_message_id" IS 'Broker-assigned message ID, where available.';;

