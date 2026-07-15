-- Create "hikcentral_gate_action_audits" table
CREATE TABLE "gates"."hikcentral_gate_action_audits" (
  "hikcentral_gate_action_audit_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "gate_command_id" uuid NOT NULL,
  "source_processing_id" uuid NOT NULL,
  "gate_authorization_consumption_id" uuid NOT NULL,
  "exit_authorization_id" uuid NOT NULL,
  "parking_session_id" uuid NOT NULL,
  "payment_attempt_id" uuid NOT NULL,
  "tariff_snapshot_id" uuid NOT NULL,
  "gate_device_id" uuid NULL,
  "service_identity_id" uuid NULL,
  "lane_id" uuid NULL,
  "site_id" uuid NULL,
  "vendor_system_id" uuid NULL,
  "vendor_code" character varying(64) NOT NULL,
  "vendor_operation" character varying(128) NOT NULL,
  "door_index_code" character varying(128) NOT NULL,
  "request_method" character varying(16) NOT NULL,
  "request_path" character varying(512) NOT NULL,
  "request_hash" character(64) NOT NULL,
  "signed_header_names" text NOT NULL,
  "request_correlation_id" uuid NOT NULL,
  "vendor_correlation_id" character varying(128) NULL,
  "http_status_code" integer NULL,
  "vendor_result_code" character varying(64) NULL,
  "vendor_result_message" character varying(256) NULL,
  "action_outcome" character varying(64) NOT NULL,
  "retryable" boolean NOT NULL,
  "failure_recorded" boolean NOT NULL,
  "duration_ms" integer NOT NULL,
  "timed_out" boolean NOT NULL,
  "vendor_unavailable" boolean NOT NULL,
  "transport_failure" boolean NOT NULL,
  "requested_at" timestamptz NOT NULL,
  "responded_at" timestamptz NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT "pk_hikcentral_gate_action_audits" PRIMARY KEY ("hikcentral_gate_action_audit_id"),
  CONSTRAINT "fk_hikcentral_gate_action_audits__gate_command_id" FOREIGN KEY ("gate_command_id")
    REFERENCES "gates"."gate_commands" ("command_id") DEFERRABLE INITIALLY IMMEDIATE,
  CONSTRAINT "ck_hikcentral_gate_action_audits__vendor"
    CHECK ("vendor_code" = 'HIKCENTRAL'),
  CONSTRAINT "ck_hikcentral_gate_action_audits__method"
    CHECK ("request_method" = 'POST'),
  CONSTRAINT "ck_hikcentral_gate_action_audits__http_status"
    CHECK ("http_status_code" IS NULL OR "http_status_code" BETWEEN 100 AND 599),
  CONSTRAINT "ck_hikcentral_gate_action_audits__duration"
    CHECK ("duration_ms" >= 0),
  CONSTRAINT "ck_hikcentral_gate_action_audits__timestamps"
    CHECK ("responded_at" >= "requested_at"),
  CONSTRAINT "ck_hikcentral_gate_action_audits__request_hash"
    CHECK ("request_hash" ~ '^[0-9a-f]{64}$'),
  CONSTRAINT "ck_hikcentral_gate_action_audits__outcome"
    CHECK ("action_outcome" IN ('SUCCEEDED', 'FAILED', 'RETRYABLE_FAILURE', 'TERMINAL_FAILURE', 'TIMEOUT', 'VENDOR_UNAVAILABLE', 'TRANSPORT_FAILURE')),
  CONSTRAINT "ck_hikcentral_gate_action_audits__failure_flags"
    CHECK (
      ("failure_recorded" = false AND "action_outcome" = 'SUCCEEDED' AND "retryable" = false AND "timed_out" = false AND "vendor_unavailable" = false AND "transport_failure" = false)
      OR ("failure_recorded" = true AND "action_outcome" <> 'SUCCEEDED')
    ),
  CONSTRAINT "ck_hikcentral_gate_action_audits__classification"
    CHECK (
      ("action_outcome" = 'TIMEOUT' AND "timed_out" = true)
      OR ("action_outcome" <> 'TIMEOUT')
    ),
  CONSTRAINT "ck_hikcentral_gate_action_audits__vendor_unavailable"
    CHECK (
      ("action_outcome" = 'VENDOR_UNAVAILABLE' AND "vendor_unavailable" = true)
      OR ("action_outcome" <> 'VENDOR_UNAVAILABLE')
    ),
  CONSTRAINT "ck_hikcentral_gate_action_audits__transport_failure"
    CHECK (
      ("action_outcome" = 'TRANSPORT_FAILURE' AND "transport_failure" = true)
      OR ("action_outcome" <> 'TRANSPORT_FAILURE')
    )
);;
