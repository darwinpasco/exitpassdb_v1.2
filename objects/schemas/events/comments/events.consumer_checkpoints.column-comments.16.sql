-- Set comment to column: "locked_by_service_identity_id" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."locked_by_service_identity_id" IS 'Consumer service identity holding the lock.';;

