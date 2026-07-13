-- Set comment to column: "row_version" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."row_version" IS 'Optimistic concurrency version for checkpoint safety.';;

