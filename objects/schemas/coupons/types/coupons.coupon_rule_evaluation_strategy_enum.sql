-- Create enum type "coupon_rule_evaluation_strategy_enum"
CREATE TYPE "coupons"."coupon_rule_evaluation_strategy_enum" AS ENUM ('ALL_RULES_MUST_PASS', 'ANY_RULE_MAY_PASS', 'FIRST_MATCH', 'PRIORITY_ORDERED');;

