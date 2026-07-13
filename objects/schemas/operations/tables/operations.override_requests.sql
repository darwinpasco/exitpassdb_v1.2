-- Create "override_requests" table
CREATE TABLE "operations"."override_requests" (
  "override_request_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "incident_record_id" uuid NULL,
  "target_entity_type" character varying(64) NULL,
  "target_entity_id" uuid NULL,
  "site_id" uuid NULL,
  "lane_id" uuid NULL,
  "override_type" "operations"."override_type_enum" NOT NULL,
  "override_reason_code" character varying(64) NOT NULL,
  "request_status" "operations"."override_request_status_enum" NOT NULL,
  "request_notes" text NULL,
  "requires_approval" boolean NOT NULL DEFAULT false,
  "requested_at" timestamptz NOT NULL,
  "requested_by_user_id" uuid NOT NULL,
  "expires_at" timestamptz NULL,
  "closed_at" timestamptz NULL,
  "closure_reason_code" character varying(64) NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_override_requests" PRIMARY KEY ("override_request_id")
);;

