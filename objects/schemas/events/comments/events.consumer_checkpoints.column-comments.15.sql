-- Set comment to column: "locked_at" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."locked_at" IS 'Timestamp when checkpoint was locked for processing.';;

