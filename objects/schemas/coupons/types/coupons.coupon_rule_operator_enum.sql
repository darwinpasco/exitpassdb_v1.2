-- Create enum type "coupon_rule_operator_enum"
CREATE TYPE "coupons"."coupon_rule_operator_enum" AS ENUM ('EQUALS', 'NOT_EQUALS', 'IN', 'NOT_IN', 'GREATER_THAN', 'GREATER_THAN_OR_EQUAL', 'LESS_THAN', 'LESS_THAN_OR_EQUAL', 'BETWEEN', 'EXISTS', 'NOT_EXISTS');;

