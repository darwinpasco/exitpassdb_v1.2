-- Set comment to column: "row_version" on table: "session_identifier_indexes"
COMMENT ON COLUMN "sessions"."session_identifier_indexes"."row_version" IS 'Optimistic concurrency version.';;

