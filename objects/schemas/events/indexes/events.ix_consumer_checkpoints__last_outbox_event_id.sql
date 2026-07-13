-- Create index "ix_consumer_checkpoints__last_outbox_event_id" to table: "consumer_checkpoints"
CREATE INDEX "ix_consumer_checkpoints__last_outbox_event_id" ON "events"."consumer_checkpoints" ("last_outbox_event_id");;

