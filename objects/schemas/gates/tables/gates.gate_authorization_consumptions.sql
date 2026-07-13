-- Create "gate_authorization_consumptions" table
CREATE TABLE "gates"."gate_authorization_consumptions" (
  "gate_authorization_consumption_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "exit_authorization_id" uuid NULL,
  "authorization_token_hash" character(64) NULL,
  "gate_device_id" uuid NULL,
  "site_id" uuid NOT NULL,
  "lane_id" uuid NULL,
  "consume_status" "gates"."gate_authorization_consumption_status_enum" NOT NULL,
  "consume_reason_code" character varying(64) NULL,
  "requested_at" timestamptz NOT NULL,
  "validated_at" timestamptz NULL,
  "consumed_at" timestamptz NULL,
  "command_requested" boolean NOT NULL DEFAULT false,
  "command_result_status" "gates"."gate_command_result_status_enum" NULL,
  "command_result_at" timestamptz NULL,
  "failure_detail" text NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_gate_authorization_consumptions" PRIMARY KEY ("gate_authorization_consumption_id")
);;

