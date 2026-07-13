-- Create "session_resolution_requests" table
CREATE TABLE "sessions"."session_resolution_requests" (
  "session_resolution_request_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "site_group_id" uuid NOT NULL,
  "site_id" uuid NULL,
  "lookup_type" "sessions"."session_lookup_type_enum" NOT NULL,
  "lookup_identifier_hash" character(64) NOT NULL,
  "lookup_identifier_masked" character varying(64) NULL,
  "request_channel" "sessions"."session_resolution_channel_enum" NOT NULL,
  "request_status" "sessions"."session_resolution_request_status_enum" NOT NULL,
  "client_reference" character varying(128) NULL,
  "idempotency_key" character varying(128) NULL,
  "rate_limit_key_hash" character(64) NULL,
  "requested_at" timestamptz NOT NULL,
  "expires_at" timestamptz NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_session_resolution_requests" PRIMARY KEY ("session_resolution_request_id")
);;

