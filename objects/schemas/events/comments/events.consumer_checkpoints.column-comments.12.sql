-- Set comment to column: "last_processed_at" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."last_processed_at" IS 'Timestamp when last event was processed.';;

