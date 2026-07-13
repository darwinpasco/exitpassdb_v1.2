-- Create "parking_sessions" table
CREATE TABLE "core"."parking_sessions" (
  "parking_session_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "site_group_id" uuid NOT NULL,
  "site_id" uuid NOT NULL,
  "vendor_system_id" uuid NOT NULL,
  "vendor_session_ref" character varying(128) NOT NULL,
  "plate_number_hash" character(64) NULL,
  "plate_number_masked" character varying(32) NULL,
  "ticket_number_hash" character(64) NULL,
  "ticket_number_masked" character varying(64) NULL,
  "entry_at" timestamptz NULL,
  "vendor_session_status" character varying(64) NULL,
  "session_status" "core"."parking_session_status_enum" NOT NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_parking_sessions" PRIMARY KEY ("parking_session_id")
);;

