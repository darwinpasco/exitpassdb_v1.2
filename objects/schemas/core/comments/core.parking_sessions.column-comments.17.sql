-- Set comment to column: "row_version" on table: "parking_sessions"
COMMENT ON COLUMN "core"."parking_sessions"."row_version" IS 'Optimistic concurrency version.';;

