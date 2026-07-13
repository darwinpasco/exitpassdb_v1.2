-- Set comment to column: "outbox_event_id" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."outbox_event_id" IS 'Canonical identifier of the outbox event.';;

