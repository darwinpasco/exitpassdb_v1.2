-- Create "user_roles" table
CREATE TABLE "identity"."user_roles" (
  "user_role_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "user_id" uuid NOT NULL,
  "role_id" uuid NOT NULL,
  "assignment_status" "identity"."user_role_assignment_status_enum" NOT NULL,
  "assignment_reason_code" character varying(64) NULL,
  "assigned_at" timestamptz NOT NULL DEFAULT now(),
  "assigned_by_user_id" uuid NULL,
  "assigned_by_service_identity_id" uuid NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "revoked_at" timestamptz NULL,
  "revoked_by_user_id" uuid NULL,
  "revoked_by_service_identity_id" uuid NULL,
  "revocation_reason_code" character varying(64) NULL,
  "last_reviewed_at" timestamptz NULL,
  "last_reviewed_by_user_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_user_roles" PRIMARY KEY ("user_role_id")
);;

