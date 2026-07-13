-- Create "vendor_endpoints" table
CREATE TABLE "integration"."vendor_endpoints" (
  "vendor_endpoint_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "vendor_system_id" uuid NOT NULL,
  "endpoint_code" character varying(96) NOT NULL,
  "endpoint_name" character varying(128) NOT NULL,
  "endpoint_description" text NULL,
  "endpoint_type" "integration"."vendor_endpoint_type_enum" NOT NULL,
  "http_method" "integration"."http_method_enum" NULL,
  "path_template" character varying(512) NULL,
  "operation_ref" character varying(128) NULL,
  "credential_reference_id" uuid NULL,
  "timeout_policy_code" character varying(64) NULL,
  "retry_policy_code" character varying(64) NULL,
  "rate_limit_policy_code" character varying(64) NULL,
  "endpoint_status" "integration"."vendor_endpoint_status_enum" NOT NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_vendor_endpoints" PRIMARY KEY ("vendor_endpoint_id"),
  CONSTRAINT "uq_vendor_endpoints__vendor_endpoint_code" UNIQUE ("vendor_system_id", "endpoint_code")
);;

