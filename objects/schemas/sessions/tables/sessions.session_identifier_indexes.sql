-- Create "session_identifier_indexes" table
CREATE TABLE "sessions"."session_identifier_indexes" (
  "session_identifier_index_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "parking_session_id" uuid NULL,
  "site_group_id" uuid NOT NULL,
  "site_id" uuid NULL,
  "vendor_system_id" uuid NULL,
  "identifier_type" "sessions"."session_lookup_type_enum" NOT NULL,
  "identifier_hash" character(64) NOT NULL,
  "identifier_masked" character varying(64) NULL,
  "identifier_status" "sessions"."session_identifier_status_enum" NOT NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_service_identity_id" uuid NULL,
  "correlation_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_session_identifier_indexes" PRIMARY KEY ("session_identifier_index_id")
);;

