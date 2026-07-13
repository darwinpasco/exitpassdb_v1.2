-- Create index "ux_coupon_applications__reservation_ref" to table: "coupon_applications"
CREATE UNIQUE INDEX "ux_coupon_applications__reservation_ref" ON "coupons"."coupon_applications" ("reservation_ref") WHERE (reservation_ref IS NOT NULL);;

