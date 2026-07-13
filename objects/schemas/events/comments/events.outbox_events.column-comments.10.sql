-- Set comment to column: "payload_ref" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."payload_ref" IS 'Reference to event payload if stored externally.';;

