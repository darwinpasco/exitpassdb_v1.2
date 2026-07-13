-- Set comment to column: "created_by_service_identity_id" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."created_by_service_identity_id" IS 'Service identity that created the outbox event.';;

