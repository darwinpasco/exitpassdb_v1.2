-- Set comment to column: "correlation_id" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."correlation_id" IS 'Cross-service correlation identifier.';;

