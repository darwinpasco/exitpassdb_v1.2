-- Set comment to column: "row_version" on table: "session_resolution_requests"
COMMENT ON COLUMN "sessions"."session_resolution_requests"."row_version" IS 'Optimistic concurrency version.';;

