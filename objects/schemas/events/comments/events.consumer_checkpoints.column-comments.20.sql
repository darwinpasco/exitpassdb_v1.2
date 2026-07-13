-- Set comment to column: "correlation_id" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."correlation_id" IS 'Cross-service correlation identifier.';;

