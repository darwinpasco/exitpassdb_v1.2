-- Create index "ix_domain_events__correlation_id" to table: "domain_events"
CREATE INDEX "ix_domain_events__correlation_id" ON "events"."domain_events" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

