-- Set comment to column: "source_schema" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."source_schema" IS 'Source schema that produced the outbox event.';;

