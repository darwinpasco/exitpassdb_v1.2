-- Set comment to column: "processed_count" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."processed_count" IS 'Count of processed events tracked by this checkpoint.';;

