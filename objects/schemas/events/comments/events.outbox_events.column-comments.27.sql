-- Set comment to column: "updated_by_service_identity_id" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."updated_by_service_identity_id" IS 'Service identity that last updated the outbox event.';;

