-- Create "integration_credential_references" table
CREATE TABLE "integration"."integration_credential_references" (
  "integration_credential_reference_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "vendor_system_id" uuid NOT NULL,
  "service_identity_id" uuid NULL,
  "credential_code" character varying(64) NOT NULL,
  "credential_name" character varying(128) NOT NULL,
  "credential_type" "integration"."integration_credential_type_enum" NOT NULL,
  "secret_store_type" "integration"."secret_store_type_enum" NOT NULL,
  "secret_reference" character varying(256) NOT NULL,
  "credential_status" "integration"."integration_credential_status_enum" NOT NULL,
  "credential_version_ref" character varying(128) NULL,
  "last_rotated_at" timestamptz NULL,
  "next_rotation_due_at" timestamptz NULL,
  "expires_at" timestamptz NULL,
  "revoked_at" timestamptz NULL,
  "revocation_reason_code" character varying(64) NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_integration_credential_references" PRIMARY KEY ("integration_credential_reference_id")
);;

