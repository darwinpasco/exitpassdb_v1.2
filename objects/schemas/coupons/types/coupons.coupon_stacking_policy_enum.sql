-- Create enum type "coupon_stacking_policy_enum"
CREATE TYPE "coupons"."coupon_stacking_policy_enum" AS ENUM ('NO_STACKING', 'STACK_WITH_STATUTORY_DISCOUNT', 'STACK_WITH_COUPON', 'STACK_WITH_BOTH', 'HIGHEST_BENEFIT_ONLY');;

