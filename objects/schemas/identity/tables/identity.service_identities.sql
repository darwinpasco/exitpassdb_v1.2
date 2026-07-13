-- Create "service_identities" table
CREATE TABLE "identity"."service_identities" (
  "service_identity_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "service_identity_code" character varying(64) NOT NULL,
  "service_identity_name" character varying(128) NOT NULL,
  "identity_type" "identity"."service_identity_type_enum" NOT NULL,
  "identity_status" "identity"."service_identity_status_enum" NOT NULL,
  "owning_service_name" character varying(128) NULL,
  "credential_reference" character varying(256) NULL,
  "credential_type" "identity"."service_credential_type_enum" NULL,
  "credential_expires_at" timestamptz NULL,
  "last_rotated_at" timestamptz NULL,
  "last_authenticated_at" timestamptz NULL,
  "revoked_at" timestamptz NULL,
  "revocation_reason_code" character varying(64) NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_service_identities" PRIMARY KEY ("service_identity_id"),
  CONSTRAINT "uq_service_identities__service_identity_code" UNIQUE ("service_identity_code")
);;

