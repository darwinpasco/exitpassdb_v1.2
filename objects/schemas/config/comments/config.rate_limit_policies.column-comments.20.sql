-- Set comment to column: "row_version" on table: "rate_limit_policies"
COMMENT ON COLUMN "config"."rate_limit_policies"."row_version" IS 'Optimistic concurrency version.';;

