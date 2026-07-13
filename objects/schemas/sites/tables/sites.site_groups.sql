-- Create "site_groups" table
CREATE TABLE "sites"."site_groups" (
  "site_group_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "site_group_code" character varying(64) NOT NULL,
  "site_group_name" character varying(128) NOT NULL,
  "business_label" character varying(64) NULL,
  "description" text NULL,
  "operator_entity_name" character varying(128) NULL,
  "timezone_name" character varying(64) NOT NULL,
  "default_currency_code" character(3) NOT NULL,
  "site_group_status" "sites"."site_group_status_enum" NOT NULL,
  "public_lookup_enabled" boolean NOT NULL DEFAULT false,
  "default_payment_enabled" boolean NOT NULL DEFAULT false,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_site_groups" PRIMARY KEY ("site_group_id"),
  CONSTRAINT "uq_site_groups__site_group_code" UNIQUE ("site_group_code")
);;

