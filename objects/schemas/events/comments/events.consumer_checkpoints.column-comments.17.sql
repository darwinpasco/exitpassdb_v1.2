-- Set comment to column: "updated_by_service_identity_id" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."updated_by_service_identity_id" IS 'Consumer service identity that last updated the checkpoint.';;

