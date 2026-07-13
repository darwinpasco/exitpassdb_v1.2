-- Create "merchant_site_scopes" table
CREATE TABLE "merchants"."merchant_site_scopes" (
  "merchant_site_scope_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "merchant_id" uuid NOT NULL,
  "site_group_id" uuid NULL,
  "site_id" uuid NULL,
  "scope_type" "merchants"."merchant_scope_type_enum" NOT NULL,
  "scope_status" "merchants"."merchant_site_scope_status_enum" NOT NULL,
  "scope_reason_code" character varying(64) NULL,
  "allows_coupon_sponsorship" boolean NOT NULL DEFAULT false,
  "allows_full_waiver" boolean NOT NULL DEFAULT false,
  "requires_elevated_approval" boolean NOT NULL DEFAULT false,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "approved_at" timestamptz NULL,
  "approved_by_user_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_merchant_site_scopes" PRIMARY KEY ("merchant_site_scope_id")
);;

