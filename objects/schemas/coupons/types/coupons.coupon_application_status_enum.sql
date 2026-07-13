-- Create enum type "coupon_application_status_enum"
CREATE TYPE "coupons"."coupon_application_status_enum" AS ENUM ('REQUESTED', 'RESERVED', 'APPLIED', 'COMMITTED', 'RELEASED', 'EXPIRED', 'REJECTED', 'CANCELLED', 'REVERSED');;

