-- Set comment to column: "retry_count" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."retry_count" IS 'Number of publication attempts.';;

