-- Create "merchant_wallets" table
CREATE TABLE "merchants"."merchant_wallets" (
  "merchant_wallet_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "merchant_id" uuid NOT NULL,
  "wallet_code" character varying(64) NOT NULL,
  "wallet_name" character varying(128) NOT NULL,
  "wallet_type" "merchants"."merchant_wallet_type_enum" NOT NULL,
  "wallet_status" "merchants"."merchant_wallet_status_enum" NOT NULL,
  "currency_code" character(3) NOT NULL,
  "available_balance" numeric(18,2) NULL,
  "reserved_balance" numeric(18,2) NULL,
  "committed_balance" numeric(18,2) NULL,
  "external_ledger_ref" character varying(128) NULL,
  "allows_coupon_funding" boolean NOT NULL DEFAULT false,
  "allows_statutory_discount_funding" boolean NOT NULL DEFAULT false,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_merchant_wallets" PRIMARY KEY ("merchant_wallet_id"),
  CONSTRAINT "uq_merchant_wallets__merchant_wallet_code" UNIQUE ("merchant_id", "wallet_code")
);;

