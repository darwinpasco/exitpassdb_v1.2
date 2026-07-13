-- Set comment to column: "locked_by_service_identity_id" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."locked_by_service_identity_id" IS 'Dispatcher service identity that locked the event.';;

