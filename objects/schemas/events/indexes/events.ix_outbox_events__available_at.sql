-- Create index "ix_outbox_events__available_at" to table: "outbox_events"
CREATE INDEX "ix_outbox_events__available_at" ON "events"."outbox_events" ("available_at");;

