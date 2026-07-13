-- Create index "ix_consumer_checkpoints__checkpoint_status" to table: "consumer_checkpoints"
CREATE INDEX "ix_consumer_checkpoints__checkpoint_status" ON "events"."consumer_checkpoints" ("checkpoint_status");;

