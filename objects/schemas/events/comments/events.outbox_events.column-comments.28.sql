-- Set comment to column: "row_version" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."row_version" IS 'Optimistic concurrency version for dispatcher safety.';;

