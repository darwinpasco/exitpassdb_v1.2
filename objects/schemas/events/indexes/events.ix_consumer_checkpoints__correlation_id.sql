-- Create index "ix_consumer_checkpoints__correlation_id" to table: "consumer_checkpoints"
CREATE INDEX "ix_consumer_checkpoints__correlation_id" ON "events"."consumer_checkpoints" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

