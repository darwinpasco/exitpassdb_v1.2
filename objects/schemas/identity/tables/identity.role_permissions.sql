-- Create "role_permissions" table
CREATE TABLE "identity"."role_permissions" (
  "role_permission_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "role_id" uuid NOT NULL,
  "permission_id" uuid NOT NULL,
  "binding_status" "identity"."role_permission_binding_status_enum" NOT NULL,
  "binding_reason_code" character varying(64) NULL,
  "assigned_at" timestamptz NOT NULL DEFAULT now(),
  "assigned_by_user_id" uuid NULL,
  "assigned_by_service_identity_id" uuid NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "revoked_at" timestamptz NULL,
  "revoked_by_user_id" uuid NULL,
  "revoked_by_service_identity_id" uuid NULL,
  "revocation_reason_code" character varying(64) NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_role_permissions" PRIMARY KEY ("role_permission_id")
);;

