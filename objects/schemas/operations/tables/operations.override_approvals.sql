-- Create "override_approvals" table
CREATE TABLE "operations"."override_approvals" (
  "override_approval_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "override_request_id" uuid NOT NULL,
  "approval_sequence" integer NOT NULL,
  "approval_decision" "operations"."override_approval_decision_enum" NOT NULL,
  "approval_reason_code" character varying(64) NULL,
  "rejection_reason_code" character varying(64) NULL,
  "approval_notes" text NULL,
  "decided_at" timestamptz NOT NULL,
  "decided_by_user_id" uuid NOT NULL,
  "expires_at" timestamptz NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  CONSTRAINT "pk_override_approvals" PRIMARY KEY ("override_approval_id")
);;

