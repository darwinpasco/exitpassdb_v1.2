-- Set comment to column: "published_at" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."published_at" IS 'Timestamp when publication succeeded.';;

