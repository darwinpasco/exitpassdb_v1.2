-- Set comment to column: "failure_count" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."failure_count" IS 'Count of processing failures tracked by this checkpoint.';;

