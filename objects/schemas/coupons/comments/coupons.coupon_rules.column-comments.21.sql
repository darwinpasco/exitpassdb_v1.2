-- Set comment to column: "row_version" on table: "coupon_rules"
COMMENT ON COLUMN "coupons"."coupon_rules"."row_version" IS 'Optimistic concurrency version.';;

