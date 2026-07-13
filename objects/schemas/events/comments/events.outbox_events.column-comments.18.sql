-- Set comment to column: "next_retry_at" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."next_retry_at" IS 'Next retry timestamp after failed publication.';;

