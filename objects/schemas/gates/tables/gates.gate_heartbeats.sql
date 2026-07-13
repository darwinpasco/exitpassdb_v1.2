-- Create "gate_heartbeats" table
CREATE TABLE "gates"."gate_heartbeats" (
  "gate_heartbeat_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "gate_device_id" uuid NOT NULL,
  "site_id" uuid NOT NULL,
  "lane_id" uuid NULL,
  "heartbeat_status" "gates"."gate_heartbeat_status_enum" NOT NULL,
  "device_reported_status" character varying(64) NULL,
  "latency_ms" integer NULL,
  "error_code" character varying(64) NULL,
  "error_detail" text NULL,
  "observed_at" timestamptz NOT NULL,
  "received_at" timestamptz NOT NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  CONSTRAINT "pk_gate_heartbeats" PRIMARY KEY ("gate_heartbeat_id")
);;

