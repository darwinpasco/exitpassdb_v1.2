-- Set comment to column: "consumer_group" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."consumer_group" IS 'Consumer group name, where applicable.';;

