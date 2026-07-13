-- Create "system_parameters" table
CREATE TABLE "config"."system_parameters" (
  "system_parameter_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "parameter_code" character varying(96) NOT NULL,
  "parameter_name" character varying(128) NOT NULL,
  "parameter_description" text NULL,
  "parameter_domain" character varying(64) NOT NULL,
  "parameter_type" "config"."system_parameter_type_enum" NOT NULL,
  "value_text" text NULL,
  "value_numeric" numeric(18,4) NULL,
  "value_boolean" boolean NULL,
  "value_json_ref" character varying(256) NULL,
  "parameter_status" "config"."system_parameter_status_enum" NOT NULL,
  "requires_approval" boolean NOT NULL DEFAULT false,
  "is_sensitive" boolean NOT NULL DEFAULT false,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "approved_at" timestamptz NULL,
  "approved_by_user_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_system_parameters" PRIMARY KEY ("system_parameter_id")
);;

