-- Set comment to column: "row_version" on table: "session_lookup_cache"
COMMENT ON COLUMN "sessions"."session_lookup_cache"."row_version" IS 'Optimistic concurrency version.';;

