-- Create "merchant_users" table
CREATE TABLE "merchants"."merchant_users" (
  "merchant_user_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "merchant_id" uuid NOT NULL,
  "user_id" uuid NOT NULL,
  "merchant_user_status" "merchants"."merchant_user_status_enum" NOT NULL,
  "merchant_user_type" "merchants"."merchant_user_type_enum" NOT NULL,
  "can_request_coupon" boolean NOT NULL DEFAULT false,
  "can_manage_coupon" boolean NOT NULL DEFAULT false,
  "can_view_wallet" boolean NOT NULL DEFAULT false,
  "can_view_reports" boolean NOT NULL DEFAULT false,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "invited_at" timestamptz NULL,
  "accepted_at" timestamptz NULL,
  "revoked_at" timestamptz NULL,
  "revoked_by_user_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_merchant_users" PRIMARY KEY ("merchant_user_id")
);;

