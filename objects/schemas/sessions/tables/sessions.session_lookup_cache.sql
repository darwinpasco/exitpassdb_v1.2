-- Create "session_lookup_cache" table
CREATE TABLE "sessions"."session_lookup_cache" (
  "session_lookup_cache_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "site_group_id" uuid NOT NULL,
  "site_id" uuid NULL,
  "parking_session_id" uuid NULL,
  "vendor_system_id" uuid NULL,
  "lookup_type" "sessions"."session_lookup_type_enum" NOT NULL,
  "lookup_identifier_hash" character(64) NOT NULL,
  "result_status" "sessions"."session_resolution_result_status_enum" NOT NULL,
  "cache_status" "sessions"."session_lookup_cache_status_enum" NOT NULL,
  "cached_at" timestamptz NOT NULL,
  "expires_at" timestamptz NOT NULL,
  "invalidated_at" timestamptz NULL,
  "invalidation_reason_code" character varying(64) NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_session_lookup_cache" PRIMARY KEY ("session_lookup_cache_id")
);;

