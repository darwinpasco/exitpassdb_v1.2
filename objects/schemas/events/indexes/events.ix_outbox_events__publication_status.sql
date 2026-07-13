-- Create index "ix_outbox_events__publication_status" to table: "outbox_events"
CREATE INDEX "ix_outbox_events__publication_status" ON "events"."outbox_events" ("publication_status");;

