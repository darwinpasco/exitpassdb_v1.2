-- Set comment to column: "payload_hash" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."payload_hash" IS 'Hash of event payload.';;

