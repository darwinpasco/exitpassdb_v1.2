-- Create index "ix_outbox_events__causation_id" to table: "outbox_events"
CREATE INDEX "ix_outbox_events__causation_id" ON "events"."outbox_events" ("causation_id") WHERE (causation_id IS NOT NULL);;

