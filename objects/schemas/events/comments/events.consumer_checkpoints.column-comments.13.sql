-- Set comment to column: "last_failed_at" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."last_failed_at" IS 'Timestamp of last processing failure.';;

