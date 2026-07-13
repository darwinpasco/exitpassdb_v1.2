-- Create "coupon_rules" table
CREATE TABLE "coupons"."coupon_rules" (
  "coupon_rule_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "coupon_rule_group_id" uuid NOT NULL,
  "rule_code" character varying(64) NOT NULL,
  "rule_name" character varying(128) NOT NULL,
  "rule_type" "coupons"."coupon_rule_type_enum" NOT NULL,
  "rule_operator" "coupons"."coupon_rule_operator_enum" NOT NULL,
  "rule_value_text" character varying(256) NULL,
  "rule_value_numeric" numeric(18,2) NULL,
  "rule_value_boolean" boolean NULL,
  "site_group_id" uuid NULL,
  "site_id" uuid NULL,
  "merchant_id" uuid NULL,
  "rule_status" "coupons"."coupon_rule_status_enum" NOT NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_coupon_rules" PRIMARY KEY ("coupon_rule_id"),
  CONSTRAINT "uq_coupon_rules__group_rule_code" UNIQUE ("coupon_rule_group_id", "rule_code")
);;

