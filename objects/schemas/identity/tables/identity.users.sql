-- Create "users" table
CREATE TABLE "identity"."users" (
  "user_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "username" character varying(128) NOT NULL,
  "email" character varying(256) NULL,
  "email_normalized" character varying(256) NULL,
  "display_name" character varying(128) NOT NULL,
  "mobile_number_masked" character varying(32) NULL,
  "user_type" "identity"."user_type_enum" NOT NULL,
  "user_status" "identity"."user_status_enum" NOT NULL,
  "last_login_at" timestamptz NULL,
  "locked_at" timestamptz NULL,
  "suspended_at" timestamptz NULL,
  "retired_at" timestamptz NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_users" PRIMARY KEY ("user_id")
);;

