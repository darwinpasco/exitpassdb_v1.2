-- Set comment to column: "event_version" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."event_version" IS 'Published event schema version.';;

