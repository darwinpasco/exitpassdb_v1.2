-- Set comment to column: "row_version" on table: "ttl_policies"
COMMENT ON COLUMN "config"."ttl_policies"."row_version" IS 'Optimistic concurrency version.';;

