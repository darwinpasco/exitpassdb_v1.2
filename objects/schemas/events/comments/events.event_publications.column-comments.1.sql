-- Set comment to column: "outbox_event_id" on table: "event_publications"
COMMENT ON COLUMN "events"."event_publications"."outbox_event_id" IS 'Outbox event being published.';;

