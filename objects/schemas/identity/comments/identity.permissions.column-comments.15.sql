-- Set comment to column: "row_version" on table: "permissions"
COMMENT ON COLUMN "identity"."permissions"."row_version" IS 'Optimistic concurrency version.';;

