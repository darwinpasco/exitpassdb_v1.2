-- Create index "ix_consumer_checkpoints__last_processed_at" to table: "consumer_checkpoints"
CREATE INDEX "ix_consumer_checkpoints__last_processed_at" ON "events"."consumer_checkpoints" ("last_processed_at");;

