-- Set comment to column: "aggregate_id" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."aggregate_id" IS 'Aggregate or source domain object identifier.';;

