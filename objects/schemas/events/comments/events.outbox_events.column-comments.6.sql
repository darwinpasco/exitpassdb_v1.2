-- Set comment to column: "aggregate_type" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."aggregate_type" IS 'Aggregate or source domain object type.';;

