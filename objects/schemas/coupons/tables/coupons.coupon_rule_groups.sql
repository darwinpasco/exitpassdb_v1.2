-- Create "coupon_rule_groups" table
CREATE TABLE "coupons"."coupon_rule_groups" (
  "coupon_rule_group_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "coupon_id" uuid NOT NULL,
  "rule_group_code" character varying(64) NOT NULL,
  "rule_group_name" character varying(128) NOT NULL,
  "rule_group_description" text NULL,
  "evaluation_strategy" "coupons"."coupon_rule_evaluation_strategy_enum" NOT NULL,
  "evaluation_priority" integer NOT NULL,
  "is_required" boolean NOT NULL DEFAULT false,
  "rule_group_status" "coupons"."coupon_rule_group_status_enum" NOT NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_coupon_rule_groups" PRIMARY KEY ("coupon_rule_group_id"),
  CONSTRAINT "uq_coupon_rule_groups__coupon_rule_group_code" UNIQUE ("coupon_id", "rule_group_code")
);;

