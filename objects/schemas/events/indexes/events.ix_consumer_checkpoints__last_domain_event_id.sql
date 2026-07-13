-- Create index "ix_consumer_checkpoints__last_domain_event_id" to table: "consumer_checkpoints"
CREATE INDEX "ix_consumer_checkpoints__last_domain_event_id" ON "events"."consumer_checkpoints" ("last_domain_event_id");;

