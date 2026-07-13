-- Set comment to column: "row_version" on table: "user_roles"
COMMENT ON COLUMN "identity"."user_roles"."row_version" IS 'Optimistic concurrency version.';;

