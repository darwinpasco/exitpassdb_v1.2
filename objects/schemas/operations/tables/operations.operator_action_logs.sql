-- Create "operator_action_logs" table
CREATE TABLE "operations"."operator_action_logs" (
  "operator_action_log_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "operator_user_id" uuid NOT NULL,
  "action_type" "operations"."operator_action_type_enum" NOT NULL,
  "action_reason_code" character varying(64) NULL,
  "target_entity_type" character varying(64) NULL,
  "target_entity_id" uuid NULL,
  "site_id" uuid NULL,
  "incident_record_id" uuid NULL,
  "action_status" "operations"."operator_action_status_enum" NOT NULL,
  "action_notes" text NULL,
  "performed_at" timestamptz NOT NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  CONSTRAINT "pk_operator_action_logs" PRIMARY KEY ("operator_action_log_id")
);;

