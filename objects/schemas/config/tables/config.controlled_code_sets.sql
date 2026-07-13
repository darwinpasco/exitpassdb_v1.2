-- Create "controlled_code_sets" table
CREATE TABLE "config"."controlled_code_sets" (
  "controlled_code_set_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "code_set_name" character varying(96) NOT NULL,
  "code_value" character varying(96) NOT NULL,
  "code_label" character varying(128) NOT NULL,
  "code_description" text NULL,
  "code_domain" character varying(64) NOT NULL,
  "code_status" "config"."controlled_code_status_enum" NOT NULL,
  "sort_order" integer NULL,
  "requires_comment" boolean NOT NULL DEFAULT false,
  "requires_approval" boolean NOT NULL DEFAULT false,
  "is_sensitive" boolean NOT NULL DEFAULT false,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_controlled_code_sets" PRIMARY KEY ("controlled_code_set_id"),
  CONSTRAINT "uq_controlled_code_sets__set_value_domain" UNIQUE ("code_set_name", "code_value", "code_domain")
);;

