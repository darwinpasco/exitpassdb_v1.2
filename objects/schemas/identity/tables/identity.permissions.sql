-- Create "permissions" table
CREATE TABLE "identity"."permissions" (
  "permission_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "permission_code" character varying(96) NOT NULL,
  "permission_name" character varying(128) NOT NULL,
  "permission_description" text NULL,
  "permission_domain" character varying(64) NOT NULL,
  "permission_action" character varying(64) NOT NULL,
  "permission_status" "identity"."permission_status_enum" NOT NULL,
  "is_sensitive" boolean NOT NULL DEFAULT false,
  "requires_audit" boolean NOT NULL DEFAULT false,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_permissions" PRIMARY KEY ("permission_id"),
  CONSTRAINT "uq_permissions__permission_code" UNIQUE ("permission_code")
);;

