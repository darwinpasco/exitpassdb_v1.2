-- Set comment to column: "row_version" on table: "role_permissions"
COMMENT ON COLUMN "identity"."role_permissions"."row_version" IS 'Optimistic concurrency version.';;

