-- Create "gate_commands" table
CREATE TABLE "gates"."gate_commands" (
  "command_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "command_type" character varying(128) NOT NULL,
  "source_processing_id" uuid NOT NULL,
  "source_event_id" uuid NULL,
  "source_event_ref" character varying(512) NULL,
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
  "command_status" character varying(32) NOT NULL,
  "attempt_count" integer NOT NULL DEFAULT 0,
  "max_attempts" integer NOT NULL DEFAULT 3,
  "retry_policy_code" character varying(128) NOT NULL DEFAULT 'GATE_COMMAND_RETRY_V1',
  "requested_at" timestamptz NOT NULL,
  "started_at" timestamptz NULL,
  "last_attempted_at" timestamptz NOT NULL,
  "next_attempt_at" timestamptz NULL,
  "completed_at" timestamptz NULL,
  "terminal_failure_at" timestamptz NULL,
  "failure_code" character varying(128) NULL,
  "failure_reason" text NULL,
  "last_failure_code" character varying(128) NULL,
  "last_failure_reason" text NULL,
  "correlation_id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT "pk_gate_commands" PRIMARY KEY ("command_id"),
  CONSTRAINT "fk_gate_commands__source_processing_id" FOREIGN KEY ("source_processing_id")
    REFERENCES "gates"."gate_authorization_consumed_processing" ("processing_id") DEFERRABLE INITIALLY IMMEDIATE,
  CONSTRAINT "fk_gate_commands__consumption" FOREIGN KEY ("gate_authorization_consumption_id")
    REFERENCES "gates"."gate_authorization_consumptions" ("gate_authorization_consumption_id") DEFERRABLE INITIALLY IMMEDIATE,
  CONSTRAINT "ck_gate_commands__status"
    CHECK ("command_status" IN ('REQUESTED', 'IN_PROGRESS', 'SUCCEEDED', 'FAILED', 'RETRYABLE', 'TERMINAL_FAILURE')),
  CONSTRAINT "ck_gate_commands__attempt_count"
    CHECK ("attempt_count" >= 0),
  CONSTRAINT "ck_gate_commands__max_attempts"
    CHECK ("max_attempts" >= 1),
  CONSTRAINT "ck_gate_commands__attempt_policy"
    CHECK ("attempt_count" <= "max_attempts"),
  CONSTRAINT "ck_gate_commands__requested_open"
    CHECK (
      "command_status" <> 'REQUESTED'
      OR ("started_at" IS NULL AND "completed_at" IS NULL AND "next_attempt_at" IS NULL AND "terminal_failure_at" IS NULL)
    ),
  CONSTRAINT "ck_gate_commands__in_progress_attempted"
    CHECK (
      "command_status" <> 'IN_PROGRESS'
      OR (("started_at" IS NOT NULL OR "last_attempted_at" IS NOT NULL) AND "completed_at" IS NULL AND "next_attempt_at" IS NULL AND "terminal_failure_at" IS NULL)
    ),
  CONSTRAINT "ck_gate_commands__completed_at"
    CHECK (
      ("command_status" IN ('SUCCEEDED', 'FAILED', 'RETRYABLE', 'TERMINAL_FAILURE') AND "completed_at" IS NOT NULL)
      OR ("command_status" IN ('REQUESTED', 'IN_PROGRESS') AND "completed_at" IS NULL)
    ),
  CONSTRAINT "ck_gate_commands__retryable_next_attempt"
    CHECK (
      ("command_status" = 'RETRYABLE' AND "next_attempt_at" IS NOT NULL)
      OR ("command_status" <> 'RETRYABLE' AND "next_attempt_at" IS NULL)
    ),
  CONSTRAINT "ck_gate_commands__terminal_failure_at"
    CHECK (
      ("command_status" = 'TERMINAL_FAILURE' AND "terminal_failure_at" IS NOT NULL)
      OR ("command_status" <> 'TERMINAL_FAILURE' AND "terminal_failure_at" IS NULL)
    ),
  CONSTRAINT "ck_gate_commands__terminal_retry_exclusive"
    CHECK (NOT ("terminal_failure_at" IS NOT NULL AND "next_attempt_at" IS NOT NULL))
);;
