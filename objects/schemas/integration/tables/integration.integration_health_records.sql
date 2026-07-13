-- Create "integration_health_records" table
CREATE TABLE "integration"."integration_health_records" (
  "integration_health_record_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "vendor_system_id" uuid NOT NULL,
  "vendor_endpoint_id" uuid NULL,
  "site_group_id" uuid NULL,
  "site_id" uuid NULL,
  "incident_record_id" uuid NULL,
  "health_status" "integration"."integration_health_status_enum" NOT NULL,
  "health_check_type" "integration"."integration_health_check_type_enum" NOT NULL,
  "http_status_code" integer NULL,
  "latency_ms" integer NULL,
  "failure_reason_code" character varying(64) NULL,
  "error_code" character varying(64) NULL,
  "error_detail_ref" character varying(256) NULL,
  "observed_at" timestamptz NOT NULL,
  "recovered_at" timestamptz NULL,
  "observed_by_service_identity_id" uuid NOT NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT "pk_integration_health_records" PRIMARY KEY ("integration_health_record_id")
);;

