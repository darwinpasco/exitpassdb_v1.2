-- Create "ttl_policies" table
CREATE TABLE "config"."ttl_policies" (
  "ttl_policy_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "policy_code" character varying(96) NOT NULL,
  "policy_name" character varying(128) NOT NULL,
  "policy_description" text NULL,
  "policy_domain" character varying(64) NOT NULL,
  "ttl_scope_type" "config"."ttl_scope_type_enum" NOT NULL,
  "ttl_seconds" integer NOT NULL,
  "grace_period_seconds" integer NULL,
  "expiry_action" "config"."ttl_expiry_action_enum" NOT NULL,
  "policy_status" "config"."ttl_policy_status_enum" NOT NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_ttl_policies" PRIMARY KEY ("ttl_policy_id"),
  CONSTRAINT "uq_ttl_policies__policy_code" UNIQUE ("policy_code")
);;

