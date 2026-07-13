-- Set comment to column: "publication_status" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."publication_status" IS 'Outbox publication lifecycle status.';;

