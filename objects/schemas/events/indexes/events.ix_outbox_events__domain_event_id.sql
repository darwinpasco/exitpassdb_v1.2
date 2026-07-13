-- Create index "ix_outbox_events__domain_event_id" to table: "outbox_events"
CREATE INDEX "ix_outbox_events__domain_event_id" ON "events"."outbox_events" ("domain_event_id");;

