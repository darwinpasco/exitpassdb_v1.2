-- Set comment to column: "row_version" on table: "feature_flags"
COMMENT ON COLUMN "config"."feature_flags"."row_version" IS 'Optimistic concurrency version.';;

