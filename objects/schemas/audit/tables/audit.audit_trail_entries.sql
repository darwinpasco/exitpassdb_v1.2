-- Create "audit_trail_entries" table
CREATE TABLE "audit"."audit_trail_entries" (
  "audit_trail_entry_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "audit_event_id" uuid NULL,
  "change_type" "audit"."audit_change_type_enum" NOT NULL,
  "target_entity_type" character varying(64) NOT NULL,
  "target_entity_id" uuid NOT NULL,
  "field_name" character varying(128) NULL,
  "before_value_hash" character(64) NULL,
  "after_value_hash" character(64) NULL,
  "before_value_redacted" text NULL,
  "after_value_redacted" text NULL,
  "change_summary" character varying(256) NULL,
  "change_reason_code" character varying(64) NULL,
  "changed_at" timestamptz NOT NULL,
  "changed_by_user_id" uuid NULL,
  "changed_by_service_identity_id" uuid NULL,
  "approval_reference_type" character varying(64) NULL,
  "approval_reference_id" uuid NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NULL,
  CONSTRAINT "pk_audit_trail_entries" PRIMARY KEY ("audit_trail_entry_id")
);;

