-- Create "merchants" table
CREATE TABLE "merchants"."merchants" (
  "merchant_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "merchant_code" character varying(64) NOT NULL,
  "merchant_name" character varying(256) NOT NULL,
  "merchant_display_name" character varying(128) NULL,
  "merchant_type" "merchants"."merchant_type_enum" NOT NULL,
  "merchant_status" "merchants"."merchant_status_enum" NOT NULL,
  "tax_identification_number_hash" character(64) NULL,
  "contact_email" character varying(256) NULL,
  "contact_mobile_masked" character varying(32) NULL,
  "default_currency_code" character(3) NOT NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_merchants" PRIMARY KEY ("merchant_id"),
  CONSTRAINT "uq_merchants__merchant_code" UNIQUE ("merchant_code")
);;

