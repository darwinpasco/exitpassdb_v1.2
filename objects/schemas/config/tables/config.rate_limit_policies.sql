-- Create "rate_limit_policies" table
CREATE TABLE "config"."rate_limit_policies" (
  "rate_limit_policy_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "policy_code" character varying(96) NOT NULL,
  "policy_name" character varying(128) NOT NULL,
  "policy_description" text NULL,
  "policy_domain" character varying(64) NOT NULL,
  "scope_type" "config"."rate_limit_scope_type_enum" NOT NULL,
  "window_seconds" integer NOT NULL,
  "max_requests" integer NOT NULL,
  "burst_limit" integer NULL,
  "penalty_seconds" integer NULL,
  "policy_status" "config"."rate_limit_policy_status_enum" NOT NULL,
  "enforcement_mode" "config"."rate_limit_enforcement_mode_enum" NOT NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_rate_limit_policies" PRIMARY KEY ("rate_limit_policy_id"),
  CONSTRAINT "uq_rate_limit_policies__policy_code" UNIQUE ("policy_code")
);;

