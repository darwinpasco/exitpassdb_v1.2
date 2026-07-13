-- Create "payment_rails" table
CREATE TABLE "payments"."payment_rails" (
  "payment_rail_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "rail_code" character varying(64) NOT NULL,
  "rail_name" character varying(128) NOT NULL,
  "provider_code" character varying(64) NOT NULL,
  "rail_type" "payments"."payment_rail_type_enum" NOT NULL,
  "supported_currency_code" character(3) NOT NULL,
  "rail_status" "payments"."payment_rail_status_enum" NOT NULL,
  "is_primary" boolean NOT NULL DEFAULT false,
  "is_fallback" boolean NOT NULL DEFAULT false,
  "provider_profile_ref" character varying(128) NULL,
  "configuration_ref" character varying(128) NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_payment_rails" PRIMARY KEY ("payment_rail_id"),
  CONSTRAINT "uq_payment_rails__rail_code" UNIQUE ("rail_code")
);;

