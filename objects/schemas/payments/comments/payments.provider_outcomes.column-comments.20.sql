-- Set comment to column: "row_version" on table: "provider_outcomes"
COMMENT ON COLUMN "payments"."provider_outcomes"."row_version" IS 'Optimistic concurrency version.';;

