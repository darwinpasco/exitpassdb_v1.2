-- Create "roles" table
CREATE TABLE "identity"."roles" (
  "role_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "role_code" character varying(64) NOT NULL,
  "role_name" character varying(128) NOT NULL,
  "role_description" text NULL,
  "role_type" "identity"."role_type_enum" NOT NULL,
  "role_status" "identity"."role_status_enum" NOT NULL,
  "is_privileged" boolean NOT NULL DEFAULT false,
  "requires_elevated_approval" boolean NOT NULL DEFAULT false,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_roles" PRIMARY KEY ("role_id"),
  CONSTRAINT "uq_roles__role_code" UNIQUE ("role_code")
);;

