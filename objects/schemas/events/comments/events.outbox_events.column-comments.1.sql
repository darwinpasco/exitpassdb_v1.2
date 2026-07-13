-- Set comment to column: "domain_event_id" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."domain_event_id" IS 'Related domain event, where domain_events is used.';;

