-- Create "vendor_systems" table
CREATE TABLE "integration"."vendor_systems" (
  "vendor_system_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "vendor_code" character varying(64) NOT NULL,
  "vendor_name" character varying(128) NOT NULL,
  "vendor_system_type" "integration"."vendor_system_type_enum" NOT NULL,
  "vendor_system_status" "integration"."vendor_system_status_enum" NOT NULL,
  "environment_code" character varying(32) NOT NULL,
  "base_url_ref" character varying(256) NULL,
  "api_version" character varying(64) NULL,
  "owner_team" character varying(128) NULL,
  "support_contact_ref" character varying(128) NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_vendor_systems" PRIMARY KEY ("vendor_system_id"),
  CONSTRAINT "uq_vendor_systems__vendor_code_environment" UNIQUE ("vendor_code", "environment_code")
);;

