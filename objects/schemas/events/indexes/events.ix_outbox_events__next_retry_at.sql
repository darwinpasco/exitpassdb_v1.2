-- Create index "ix_outbox_events__next_retry_at" to table: "outbox_events"
CREATE INDEX "ix_outbox_events__next_retry_at" ON "events"."outbox_events" ("next_retry_at");;

