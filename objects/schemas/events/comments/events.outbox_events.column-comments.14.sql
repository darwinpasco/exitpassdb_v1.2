-- Set comment to column: "available_at" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."available_at" IS 'Timestamp when event becomes eligible for dispatch.';;

