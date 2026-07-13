-- Set comment to column: "locked_at" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."locked_at" IS 'Timestamp when dispatcher locked the event for processing.';;

