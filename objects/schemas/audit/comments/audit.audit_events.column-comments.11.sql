-- Set comment to column: "source_channel" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."source_channel" IS 'Source channel, such as Web Pay, API, worker, gate, or admin UI.';;

