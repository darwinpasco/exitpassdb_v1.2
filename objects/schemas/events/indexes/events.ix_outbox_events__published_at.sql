-- Create index "ix_outbox_events__published_at" to table: "outbox_events"
CREATE INDEX "ix_outbox_events__published_at" ON "events"."outbox_events" ("published_at");;

