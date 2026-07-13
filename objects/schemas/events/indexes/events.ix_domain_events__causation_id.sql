-- Create index "ix_domain_events__causation_id" to table: "domain_events"
CREATE INDEX "ix_domain_events__causation_id" ON "events"."domain_events" ("causation_id") WHERE (causation_id IS NOT NULL);;

