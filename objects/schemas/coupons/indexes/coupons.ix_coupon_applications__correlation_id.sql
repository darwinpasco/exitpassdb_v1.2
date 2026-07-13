-- Create index "ix_coupon_applications__correlation_id" to table: "coupon_applications"
CREATE INDEX "ix_coupon_applications__correlation_id" ON "coupons"."coupon_applications" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

