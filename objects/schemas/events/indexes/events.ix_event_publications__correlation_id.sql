-- Create index "ix_event_publications__correlation_id" to table: "event_publications"
CREATE INDEX "ix_event_publications__correlation_id" ON "events"."event_publications" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

