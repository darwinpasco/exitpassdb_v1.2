-- Set comment to column: "checkpoint_status" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."checkpoint_status" IS 'Checkpoint lifecycle or processing status.';;

