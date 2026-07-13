-- Set comment to column: "row_version" on table: "roles"
COMMENT ON COLUMN "identity"."roles"."row_version" IS 'Optimistic concurrency version.';;

