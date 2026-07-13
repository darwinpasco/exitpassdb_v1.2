-- Create index "ux_outbox_events__domain_event" to table: "outbox_events"
CREATE UNIQUE INDEX "ux_outbox_events__domain_event" ON "events"."outbox_events" ("domain_event_id") WHERE (domain_event_id IS NOT NULL);;

