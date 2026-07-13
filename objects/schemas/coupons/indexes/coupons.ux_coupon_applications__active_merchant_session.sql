-- Create index "ux_coupon_applications__active_merchant_session" to table: "coupon_applications"
CREATE UNIQUE INDEX "ux_coupon_applications__active_merchant_session" ON "coupons"."coupon_applications" ("merchant_id", "parking_session_id") WHERE (application_status = ANY (ARRAY['REQUESTED'::coupons.coupon_application_status_enum, 'RESERVED'::coupons.coupon_application_status_enum, 'APPLIED'::coupons.coupon_application_status_enum]));;

