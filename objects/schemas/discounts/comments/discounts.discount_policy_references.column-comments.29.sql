-- Set comment to column: "row_version" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."row_version" IS 'Optimistic concurrency version.';;

