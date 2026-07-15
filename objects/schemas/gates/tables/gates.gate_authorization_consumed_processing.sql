-- Create "gate_authorization_consumed_processing" table
CREATE TABLE "gates"."gate_authorization_consumed_processing" (
  "processing_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "processing_key" uuid NOT NULL,
  "event_id" uuid NULL,
  "event_type" character varying(128) NOT NULL,
  "event_ref" character varying(512) NULL,
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
  "consumed_at" timestamptz NOT NULL,
  "correlation_id" uuid NOT NULL,
  "processing_status" character varying(32) NOT NULL,
  "processing_result" character varying(128) NOT NULL,
  "attempt_count" integer NOT NULL DEFAULT 0,
  "first_attempted_at" timestamptz NOT NULL,
  "last_attempted_at" timestamptz NULL,
  "processed_at" timestamptz NULL,
  "failure_code" character varying(128) NULL,
  "failure_reason" text NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT "pk_gate_authorization_consumed_processing" PRIMARY KEY ("processing_id"),
  CONSTRAINT "fk_gate_auth_consumed_processing__consumption" FOREIGN KEY ("gate_authorization_consumption_id")
    REFERENCES "gates"."gate_authorization_consumptions" ("gate_authorization_consumption_id") DEFERRABLE INITIALLY IMMEDIATE,
  CONSTRAINT "ck_gate_auth_consumed_processing__status"
    CHECK ("processing_status" IN ('PROCESSING', 'PROCESSED', 'FAILED')),
  CONSTRAINT "ck_gate_auth_consumed_processing__attempt_count"
    CHECK ("attempt_count" >= 0),
  CONSTRAINT "ck_gate_auth_consumed_processing__processed_at"
    CHECK (
      ("processing_status" = 'PROCESSED' AND "processed_at" IS NOT NULL)
      OR ("processing_status" <> 'PROCESSED' AND "processed_at" IS NULL)
    )
);;
