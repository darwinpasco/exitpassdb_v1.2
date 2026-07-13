-- Create "gate_events" table
CREATE TABLE "gates"."gate_events" (
  "gate_event_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "gate_device_id" uuid NULL,
  "gate_authorization_consumption_id" uuid NULL,
  "exit_authorization_id" uuid NULL,
  "site_id" uuid NOT NULL,
  "lane_id" uuid NULL,
  "event_type" "gates"."gate_event_type_enum" NOT NULL,
  "event_status" "gates"."gate_event_status_enum" NOT NULL,
  "event_reason_code" character varying(64) NULL,
  "event_payload_ref" character varying(256) NULL,
  "event_payload_hash" character(64) NULL,
  "source_event_ref" character varying(128) NULL,
  "occurred_at" timestamptz NOT NULL,
  "received_at" timestamptz NOT NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  CONSTRAINT "pk_gate_events" PRIMARY KEY ("gate_event_id")
);;

