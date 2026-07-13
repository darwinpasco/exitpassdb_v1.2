-- Set comment to column: "row_version" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."row_version" IS 'Optimistic concurrency version if status can change.';;

