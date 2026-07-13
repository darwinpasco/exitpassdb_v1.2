-- Create index "ix_event_publications__outbox_event_id" to table: "event_publications"
CREATE INDEX "ix_event_publications__outbox_event_id" ON "events"."event_publications" ("outbox_event_id");;

