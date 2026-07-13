-- Set comment to column: "row_version" on table: "provider_sessions"
COMMENT ON COLUMN "payments"."provider_sessions"."row_version" IS 'Optimistic concurrency version.';;

