-- Create index "ix_outbox_events__correlation_id" to table: "outbox_events"
CREATE INDEX "ix_outbox_events__correlation_id" ON "events"."outbox_events" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

