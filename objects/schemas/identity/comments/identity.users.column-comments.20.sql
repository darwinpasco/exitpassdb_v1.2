-- Set comment to column: "row_version" on table: "users"
COMMENT ON COLUMN "identity"."users"."row_version" IS 'Optimistic concurrency version.';;

