-- Set comment to column: "max_retry_count" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."max_retry_count" IS 'Maximum allowed retry attempts before dead-letter handling.';;

