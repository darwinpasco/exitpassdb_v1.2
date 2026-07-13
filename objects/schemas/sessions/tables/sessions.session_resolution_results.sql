-- Create "session_resolution_results" table
CREATE TABLE "sessions"."session_resolution_results" (
  "session_resolution_result_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "session_resolution_request_id" uuid NOT NULL,
  "parking_session_id" uuid NULL,
  "site_group_id" uuid NOT NULL,
  "site_id" uuid NULL,
  "vendor_system_id" uuid NULL,
  "vendor_session_ref" character varying(128) NULL,
  "result_status" "sessions"."session_resolution_result_status_enum" NOT NULL,
  "match_count" integer NOT NULL,
  "ambiguity_reason_code" character varying(64) NULL,
  "failure_reason_code" character varying(64) NULL,
  "resolved_at" timestamptz NOT NULL,
  "expires_at" timestamptz NULL,
  "raw_result_ref" character varying(256) NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  CONSTRAINT "pk_session_resolution_results" PRIMARY KEY ("session_resolution_result_id")
);;

