-- Create extension "pgcrypto"
CREATE EXTENSION "pgcrypto" WITH SCHEMA "public" VERSION "1.3";
-- Add new schema named "audit"
CREATE SCHEMA "audit";
-- Add new schema named "config"
CREATE SCHEMA "config";
-- Add new schema named "core"
CREATE SCHEMA "core";
-- Add new schema named "coupons"
CREATE SCHEMA "coupons";
-- Add new schema named "discounts"
CREATE SCHEMA "discounts";
-- Add new schema named "events"
CREATE SCHEMA "events";
-- Add new schema named "gates"
CREATE SCHEMA "gates";
-- Add new schema named "identity"
CREATE SCHEMA "identity";
-- Add new schema named "integration"
CREATE SCHEMA "integration";
-- Add new schema named "merchants"
CREATE SCHEMA "merchants";
-- Add new schema named "operations"
CREATE SCHEMA "operations";
-- Add new schema named "payments"
CREATE SCHEMA "payments";
-- Add new schema named "reconciliation"
CREATE SCHEMA "reconciliation";
-- Add new schema named "sessions"
CREATE SCHEMA "sessions";
-- Add new schema named "sites"
CREATE SCHEMA "sites";
-- Create enum type "audit_change_type_enum"
CREATE TYPE "audit"."audit_change_type_enum" AS ENUM ('CREATE', 'UPDATE', 'DELETE', 'ACTIVATE', 'SUSPEND', 'REVOKE', 'RETIRE', 'APPROVE', 'REJECT', 'CONFIGURE', 'ROTATE_CREDENTIAL_REFERENCE', 'CORRECT', 'MIGRATE');
-- Create enum type "audit_event_category_enum"
CREATE TYPE "audit"."audit_event_category_enum" AS ENUM ('DOMAIN_STATE_CHANGE', 'ACCESS', 'CONFIGURATION_CHANGE', 'POLICY_CHANGE', 'SECURITY_RELEVANT', 'INTEGRATION', 'RECONCILIATION', 'MANUAL_OPERATION', 'EVIDENCE_ACCESS', 'EVENTING', 'SYSTEM');
-- Create enum type "audit_event_result_enum"
CREATE TYPE "audit"."audit_event_result_enum" AS ENUM ('SUCCESS', 'FAILED', 'DENIED', 'REJECTED', 'EXPIRED', 'CANCELLED', 'DUPLICATE', 'NO_OP', 'UNKNOWN');
-- Create enum type "evidence_access_classification_enum"
CREATE TYPE "audit"."evidence_access_classification_enum" AS ENUM ('INTERNAL', 'RESTRICTED', 'HIGHLY_RESTRICTED');
-- Create enum type "evidence_link_status_enum"
CREATE TYPE "audit"."evidence_link_status_enum" AS ENUM ('ACTIVE', 'REDACTED', 'PURGED', 'HASH_ONLY', 'REVOKED');
-- Create enum type "evidence_redaction_status_enum"
CREATE TYPE "audit"."evidence_redaction_status_enum" AS ENUM ('NOT_REDACTED', 'PARTIALLY_REDACTED', 'FULLY_REDACTED', 'HASH_ONLY');
-- Create enum type "evidence_storage_type_enum"
CREATE TYPE "audit"."evidence_storage_type_enum" AS ENUM ('OBJECT_STORAGE', 'EVIDENCE_VAULT', 'HASH_ONLY', 'EXTERNAL_REFERENCE', 'REDACTED_REFERENCE');
-- Create enum type "evidence_type_enum"
CREATE TYPE "audit"."evidence_type_enum" AS ENUM ('PROVIDER_PAYLOAD', 'PROVIDER_RESPONSE', 'STATUTORY_DISCOUNT_EVIDENCE', 'MANUAL_GATE_EVIDENCE', 'INCIDENT_EVIDENCE', 'RECONCILIATION_EVIDENCE', 'SETTLEMENT_EVIDENCE', 'CONFIGURATION_CHANGE_EVIDENCE', 'SECURITY_EVIDENCE', 'SCREENSHOT', 'DOCUMENT', 'HASH_ONLY_REFERENCE', 'OTHER');
-- Create enum type "security_event_category_enum"
CREATE TYPE "audit"."security_event_category_enum" AS ENUM ('AUTHENTICATION', 'AUTHORIZATION', 'REPLAY', 'RATE_LIMIT', 'WEBHOOK_TRUST', 'TOKEN_VALIDATION', 'EVIDENCE_ACCESS', 'PRIVILEGED_ACCESS', 'CREDENTIAL_REFERENCE', 'SERVICE_IDENTITY', 'SUSPICIOUS_ACTIVITY', 'DATA_ACCESS', 'CONFIGURATION_SECURITY');
-- Create enum type "security_event_result_enum"
CREATE TYPE "audit"."security_event_result_enum" AS ENUM ('ALLOWED', 'DENIED', 'FAILED', 'BLOCKED', 'REJECTED', 'DETECTED', 'ESCALATED', 'UNKNOWN');
-- Create enum type "security_event_status_enum"
CREATE TYPE "audit"."security_event_status_enum" AS ENUM ('OPEN', 'ACKNOWLEDGED', 'UNDER_REVIEW', 'RESOLVED', 'FALSE_POSITIVE', 'ESCALATED', 'CLOSED');
-- Create enum type "security_severity_enum"
CREATE TYPE "audit"."security_severity_enum" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL');
-- Create "audit_events" table
CREATE TABLE "audit"."audit_events" (
  "audit_event_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "event_type" character varying(96) NOT NULL,
  "event_category" "audit"."audit_event_category_enum" NOT NULL,
  "event_result" "audit"."audit_event_result_enum" NOT NULL,
  "event_reason_code" character varying(64) NULL,
  "target_entity_type" character varying(64) NULL,
  "target_entity_id" uuid NULL,
  "related_entity_type" character varying(64) NULL,
  "related_entity_id" uuid NULL,
  "source_schema" character varying(64) NULL,
  "source_service_name" character varying(128) NULL,
  "source_channel" character varying(64) NULL,
  "actor_user_id" uuid NULL,
  "actor_service_identity_id" uuid NULL,
  "actor_ip_hash" character(64) NULL,
  "actor_user_agent_hash" character(64) NULL,
  "summary" character varying(256) NULL,
  "details_ref" character varying(256) NULL,
  "details_hash" character(64) NULL,
  "occurred_at" timestamptz NOT NULL,
  "recorded_at" timestamptz NOT NULL DEFAULT now(),
  "correlation_id" uuid NULL,
  "causation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NULL,
  CONSTRAINT "pk_audit_events" PRIMARY KEY ("audit_event_id")
);
-- Create index "ix_audit_events__actor_service_identity_id" to table: "audit_events"
CREATE INDEX "ix_audit_events__actor_service_identity_id" ON "audit"."audit_events" ("actor_service_identity_id");
-- Create index "ix_audit_events__actor_user_id" to table: "audit_events"
CREATE INDEX "ix_audit_events__actor_user_id" ON "audit"."audit_events" ("actor_user_id");
-- Create index "ix_audit_events__causation_id" to table: "audit_events"
CREATE INDEX "ix_audit_events__causation_id" ON "audit"."audit_events" ("causation_id") WHERE (causation_id IS NOT NULL);
-- Create index "ix_audit_events__correlation_id" to table: "audit_events"
CREATE INDEX "ix_audit_events__correlation_id" ON "audit"."audit_events" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_audit_events__created_by_service_identity_id" to table: "audit_events"
CREATE INDEX "ix_audit_events__created_by_service_identity_id" ON "audit"."audit_events" ("created_by_service_identity_id");
-- Create index "ix_audit_events__occurred_at" to table: "audit_events"
CREATE INDEX "ix_audit_events__occurred_at" ON "audit"."audit_events" ("occurred_at");
-- Create index "ix_audit_events__recorded_at" to table: "audit_events"
CREATE INDEX "ix_audit_events__recorded_at" ON "audit"."audit_events" ("recorded_at");
-- Set comment to table: "audit_events"
COMMENT ON TABLE "audit"."audit_events" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "audit_event_id" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."audit_event_id" IS 'Canonical identifier of the audit event.';
-- Set comment to column: "event_type" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."event_type" IS 'Controlled audit event type.';
-- Set comment to column: "event_category" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."event_category" IS 'Audit event category.';
-- Set comment to column: "event_result" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."event_result" IS 'Event result classification.';
-- Set comment to column: "event_reason_code" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."event_reason_code" IS 'Controlled reason code explaining result.';
-- Set comment to column: "target_entity_type" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."target_entity_type" IS 'Type of affected domain entity.';
-- Set comment to column: "target_entity_id" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."target_entity_id" IS 'Identifier of affected domain entity.';
-- Set comment to column: "related_entity_type" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."related_entity_type" IS 'Type of related domain entity, where applicable.';
-- Set comment to column: "related_entity_id" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."related_entity_id" IS 'Identifier of related domain entity.';
-- Set comment to column: "source_schema" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."source_schema" IS 'Source schema or domain that produced the audit event.';
-- Set comment to column: "source_service_name" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."source_service_name" IS 'Source service that produced the event.';
-- Set comment to column: "source_channel" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."source_channel" IS 'Source channel, such as Web Pay, API, worker, gate, or admin UI.';
-- Set comment to column: "actor_user_id" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."actor_user_id" IS 'Human actor, where applicable.';
-- Set comment to column: "actor_service_identity_id" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."actor_service_identity_id" IS 'Service, adapter, job, or device actor, where applicable.';
-- Set comment to column: "actor_ip_hash" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."actor_ip_hash" IS 'Hash of actor IP where retained.';
-- Set comment to column: "actor_user_agent_hash" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."actor_user_agent_hash" IS 'Hash of user agent where retained.';
-- Set comment to column: "summary" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."summary" IS 'Short audit summary.';
-- Set comment to column: "details_ref" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."details_ref" IS 'Reference to structured audit details if stored separately.';
-- Set comment to column: "details_hash" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."details_hash" IS 'Hash of details payload where retained.';
-- Set comment to column: "occurred_at" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."occurred_at" IS 'Timestamp when audited event occurred.';
-- Set comment to column: "recorded_at" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."recorded_at" IS 'Timestamp when audit event was recorded.';
-- Set comment to column: "correlation_id" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "causation_id" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."causation_id" IS 'Causation identifier where applicable.';
-- Set comment to column: "created_at" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_service_identity_id" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."created_by_service_identity_id" IS 'Service identity that wrote the audit event.';
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
);
-- Create index "ix_audit_trail_entries__audit_event_id" to table: "audit_trail_entries"
CREATE INDEX "ix_audit_trail_entries__audit_event_id" ON "audit"."audit_trail_entries" ("audit_event_id");
-- Create index "ix_audit_trail_entries__changed_at" to table: "audit_trail_entries"
CREATE INDEX "ix_audit_trail_entries__changed_at" ON "audit"."audit_trail_entries" ("changed_at");
-- Create index "ix_audit_trail_entries__changed_by_service_identity_id" to table: "audit_trail_entries"
CREATE INDEX "ix_audit_trail_entries__changed_by_service_identity_id" ON "audit"."audit_trail_entries" ("changed_by_service_identity_id");
-- Create index "ix_audit_trail_entries__changed_by_user_id" to table: "audit_trail_entries"
CREATE INDEX "ix_audit_trail_entries__changed_by_user_id" ON "audit"."audit_trail_entries" ("changed_by_user_id");
-- Create index "ix_audit_trail_entries__correlation_id" to table: "audit_trail_entries"
CREATE INDEX "ix_audit_trail_entries__correlation_id" ON "audit"."audit_trail_entries" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_audit_trail_entries__created_by_service_identity_id" to table: "audit_trail_entries"
CREATE INDEX "ix_audit_trail_entries__created_by_service_identity_id" ON "audit"."audit_trail_entries" ("created_by_service_identity_id");
-- Set comment to table: "audit_trail_entries"
COMMENT ON TABLE "audit"."audit_trail_entries" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "audit_trail_entry_id" on table: "audit_trail_entries"
COMMENT ON COLUMN "audit"."audit_trail_entries"."audit_trail_entry_id" IS 'Canonical identifier of the audit trail entry.';
-- Set comment to column: "audit_event_id" on table: "audit_trail_entries"
COMMENT ON COLUMN "audit"."audit_trail_entries"."audit_event_id" IS 'Parent audit event, where applicable.';
-- Set comment to column: "change_type" on table: "audit_trail_entries"
COMMENT ON COLUMN "audit"."audit_trail_entries"."change_type" IS 'Type of change recorded.';
-- Set comment to column: "target_entity_type" on table: "audit_trail_entries"
COMMENT ON COLUMN "audit"."audit_trail_entries"."target_entity_type" IS 'Type of changed entity.';
-- Set comment to column: "target_entity_id" on table: "audit_trail_entries"
COMMENT ON COLUMN "audit"."audit_trail_entries"."target_entity_id" IS 'Identifier of changed entity.';
-- Set comment to column: "field_name" on table: "audit_trail_entries"
COMMENT ON COLUMN "audit"."audit_trail_entries"."field_name" IS 'Field that changed, if field-level trail is used.';
-- Set comment to column: "before_value_hash" on table: "audit_trail_entries"
COMMENT ON COLUMN "audit"."audit_trail_entries"."before_value_hash" IS 'Hash of previous value where value is sensitive or large.';
-- Set comment to column: "after_value_hash" on table: "audit_trail_entries"
COMMENT ON COLUMN "audit"."audit_trail_entries"."after_value_hash" IS 'Hash of new value where value is sensitive or large.';
-- Set comment to column: "before_value_redacted" on table: "audit_trail_entries"
COMMENT ON COLUMN "audit"."audit_trail_entries"."before_value_redacted" IS 'Redacted before value, where allowed.';
-- Set comment to column: "after_value_redacted" on table: "audit_trail_entries"
COMMENT ON COLUMN "audit"."audit_trail_entries"."after_value_redacted" IS 'Redacted after value, where allowed.';
-- Set comment to column: "change_summary" on table: "audit_trail_entries"
COMMENT ON COLUMN "audit"."audit_trail_entries"."change_summary" IS 'Short summary of change.';
-- Set comment to column: "change_reason_code" on table: "audit_trail_entries"
COMMENT ON COLUMN "audit"."audit_trail_entries"."change_reason_code" IS 'Controlled reason for change.';
-- Set comment to column: "changed_at" on table: "audit_trail_entries"
COMMENT ON COLUMN "audit"."audit_trail_entries"."changed_at" IS 'Timestamp when change occurred.';
-- Set comment to column: "changed_by_user_id" on table: "audit_trail_entries"
COMMENT ON COLUMN "audit"."audit_trail_entries"."changed_by_user_id" IS 'Human actor responsible for change.';
-- Set comment to column: "changed_by_service_identity_id" on table: "audit_trail_entries"
COMMENT ON COLUMN "audit"."audit_trail_entries"."changed_by_service_identity_id" IS 'Service actor responsible for change.';
-- Set comment to column: "approval_reference_type" on table: "audit_trail_entries"
COMMENT ON COLUMN "audit"."audit_trail_entries"."approval_reference_type" IS 'Approval entity type, where change was approved.';
-- Set comment to column: "approval_reference_id" on table: "audit_trail_entries"
COMMENT ON COLUMN "audit"."audit_trail_entries"."approval_reference_id" IS 'Approval entity ID, where change was approved.';
-- Set comment to column: "correlation_id" on table: "audit_trail_entries"
COMMENT ON COLUMN "audit"."audit_trail_entries"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "audit_trail_entries"
COMMENT ON COLUMN "audit"."audit_trail_entries"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_service_identity_id" on table: "audit_trail_entries"
COMMENT ON COLUMN "audit"."audit_trail_entries"."created_by_service_identity_id" IS 'Service identity that wrote the audit trail entry.';
-- Create "evidence_links" table
CREATE TABLE "audit"."evidence_links" (
  "evidence_link_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "audit_event_id" uuid NULL,
  "security_event_id" uuid NULL,
  "target_entity_type" character varying(64) NULL,
  "target_entity_id" uuid NULL,
  "evidence_type" "audit"."evidence_type_enum" NOT NULL,
  "evidence_storage_type" "audit"."evidence_storage_type_enum" NOT NULL,
  "evidence_storage_ref" character varying(256) NULL,
  "evidence_hash" character(64) NULL,
  "access_classification" "audit"."evidence_access_classification_enum" NOT NULL,
  "retention_policy_code" character varying(64) NOT NULL,
  "retention_expires_at" timestamptz NULL,
  "redaction_status" "audit"."evidence_redaction_status_enum" NOT NULL,
  "link_status" "audit"."evidence_link_status_enum" NOT NULL,
  "linked_at" timestamptz NOT NULL DEFAULT now(),
  "linked_by_user_id" uuid NULL,
  "linked_by_service_identity_id" uuid NULL,
  "purged_at" timestamptz NULL,
  "purged_by_user_id" uuid NULL,
  "purged_by_service_identity_id" uuid NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_evidence_links" PRIMARY KEY ("evidence_link_id")
);
-- Create index "ix_evidence_links__audit_event_id" to table: "evidence_links"
CREATE INDEX "ix_evidence_links__audit_event_id" ON "audit"."evidence_links" ("audit_event_id");
-- Create index "ix_evidence_links__correlation_id" to table: "evidence_links"
CREATE INDEX "ix_evidence_links__correlation_id" ON "audit"."evidence_links" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_evidence_links__linked_by_service_identity_id" to table: "evidence_links"
CREATE INDEX "ix_evidence_links__linked_by_service_identity_id" ON "audit"."evidence_links" ("linked_by_service_identity_id");
-- Create index "ix_evidence_links__linked_by_user_id" to table: "evidence_links"
CREATE INDEX "ix_evidence_links__linked_by_user_id" ON "audit"."evidence_links" ("linked_by_user_id");
-- Create index "ix_evidence_links__purged_by_user_id" to table: "evidence_links"
CREATE INDEX "ix_evidence_links__purged_by_user_id" ON "audit"."evidence_links" ("purged_by_user_id");
-- Create index "ix_evidence_links__retention_expires_at" to table: "evidence_links"
CREATE INDEX "ix_evidence_links__retention_expires_at" ON "audit"."evidence_links" ("retention_expires_at");
-- Create index "ix_evidence_links__security_event_id" to table: "evidence_links"
CREATE INDEX "ix_evidence_links__security_event_id" ON "audit"."evidence_links" ("security_event_id");
-- Set comment to table: "evidence_links"
COMMENT ON TABLE "audit"."evidence_links" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "evidence_link_id" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."evidence_link_id" IS 'Canonical identifier of the evidence link.';
-- Set comment to column: "audit_event_id" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."audit_event_id" IS 'Audit event supported by the evidence.';
-- Set comment to column: "security_event_id" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."security_event_id" IS 'Security event supported by the evidence.';
-- Set comment to column: "target_entity_type" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."target_entity_type" IS 'Domain entity type supported by the evidence.';
-- Set comment to column: "target_entity_id" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."target_entity_id" IS 'Domain entity identifier supported by the evidence.';
-- Set comment to column: "evidence_type" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."evidence_type" IS 'Type of evidence.';
-- Set comment to column: "evidence_storage_type" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."evidence_storage_type" IS 'Storage mechanism or reference type.';
-- Set comment to column: "evidence_storage_ref" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."evidence_storage_ref" IS 'Object key, evidence vault reference, URI reference, or controlled storage reference.';
-- Set comment to column: "evidence_hash" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."evidence_hash" IS 'Hash of evidence content where retained.';
-- Set comment to column: "access_classification" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."access_classification" IS 'Access classification.';
-- Set comment to column: "retention_policy_code" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."retention_policy_code" IS 'Retention policy applied to evidence.';
-- Set comment to column: "retention_expires_at" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."retention_expires_at" IS 'Timestamp when evidence becomes eligible for purge or redaction.';
-- Set comment to column: "redaction_status" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."redaction_status" IS 'Redaction or minimization state.';
-- Set comment to column: "link_status" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."link_status" IS 'Evidence link lifecycle state.';
-- Set comment to column: "linked_at" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."linked_at" IS 'Timestamp when evidence was linked.';
-- Set comment to column: "linked_by_user_id" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."linked_by_user_id" IS 'User who linked the evidence.';
-- Set comment to column: "linked_by_service_identity_id" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."linked_by_service_identity_id" IS 'Service identity that linked the evidence.';
-- Set comment to column: "purged_at" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."purged_at" IS 'Timestamp when evidence payload was purged, if applicable.';
-- Set comment to column: "purged_by_user_id" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."purged_by_user_id" IS 'User who purged the evidence.';
-- Set comment to column: "purged_by_service_identity_id" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."purged_by_service_identity_id" IS 'Service identity that purged the evidence.';
-- Set comment to column: "correlation_id" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."created_by_user_id" IS 'User who created the evidence link.';
-- Set comment to column: "created_by_service_identity_id" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."created_by_service_identity_id" IS 'Service identity that created the evidence link.';
-- Set comment to column: "updated_at" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."updated_by_user_id" IS 'User who last updated the evidence link.';
-- Set comment to column: "updated_by_service_identity_id" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."updated_by_service_identity_id" IS 'Service identity that last updated the evidence link.';
-- Set comment to column: "row_version" on table: "evidence_links"
COMMENT ON COLUMN "audit"."evidence_links"."row_version" IS 'Optimistic concurrency version.';
-- Create "security_events" table
CREATE TABLE "audit"."security_events" (
  "security_event_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "audit_event_id" uuid NULL,
  "security_event_type" character varying(96) NOT NULL,
  "security_event_category" "audit"."security_event_category_enum" NOT NULL,
  "security_severity" "audit"."security_severity_enum" NOT NULL,
  "security_event_status" "audit"."security_event_status_enum" NOT NULL,
  "result" "audit"."security_event_result_enum" NOT NULL,
  "reason_code" character varying(64) NULL,
  "target_entity_type" character varying(64) NULL,
  "target_entity_id" uuid NULL,
  "actor_user_id" uuid NULL,
  "actor_service_identity_id" uuid NULL,
  "source_ip_hash" character(64) NULL,
  "user_agent_hash" character(64) NULL,
  "request_fingerprint_hash" character(64) NULL,
  "incident_record_id" uuid NULL,
  "detected_at" timestamptz NOT NULL,
  "recorded_at" timestamptz NOT NULL DEFAULT now(),
  "resolved_at" timestamptz NULL,
  "resolved_by_user_id" uuid NULL,
  "resolution_reason_code" character varying(64) NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_security_events" PRIMARY KEY ("security_event_id")
);
-- Create index "ix_security_events__actor_service_identity_id" to table: "security_events"
CREATE INDEX "ix_security_events__actor_service_identity_id" ON "audit"."security_events" ("actor_service_identity_id");
-- Create index "ix_security_events__actor_user_id" to table: "security_events"
CREATE INDEX "ix_security_events__actor_user_id" ON "audit"."security_events" ("actor_user_id");
-- Create index "ix_security_events__audit_event_id" to table: "security_events"
CREATE INDEX "ix_security_events__audit_event_id" ON "audit"."security_events" ("audit_event_id");
-- Create index "ix_security_events__correlation_id" to table: "security_events"
CREATE INDEX "ix_security_events__correlation_id" ON "audit"."security_events" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_security_events__created_by_service_identity_id" to table: "security_events"
CREATE INDEX "ix_security_events__created_by_service_identity_id" ON "audit"."security_events" ("created_by_service_identity_id");
-- Create index "ix_security_events__incident_record_id" to table: "security_events"
CREATE INDEX "ix_security_events__incident_record_id" ON "audit"."security_events" ("incident_record_id");
-- Create index "ix_security_events__resolved_by_user_id" to table: "security_events"
CREATE INDEX "ix_security_events__resolved_by_user_id" ON "audit"."security_events" ("resolved_by_user_id");
-- Set comment to table: "security_events"
COMMENT ON TABLE "audit"."security_events" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "security_event_id" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."security_event_id" IS 'Canonical identifier of the security event.';
-- Set comment to column: "audit_event_id" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."audit_event_id" IS 'Related audit event, where applicable.';
-- Set comment to column: "security_event_type" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."security_event_type" IS 'Controlled security event type.';
-- Set comment to column: "security_event_category" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."security_event_category" IS 'Security event category.';
-- Set comment to column: "security_severity" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."security_severity" IS 'Severity of security event.';
-- Set comment to column: "security_event_status" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."security_event_status" IS 'Security event lifecycle or handling state.';
-- Set comment to column: "result" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."result" IS 'Result classification.';
-- Set comment to column: "reason_code" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."reason_code" IS 'Controlled security reason.';
-- Set comment to column: "target_entity_type" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."target_entity_type" IS 'Target entity type.';
-- Set comment to column: "target_entity_id" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."target_entity_id" IS 'Target entity ID.';
-- Set comment to column: "actor_user_id" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."actor_user_id" IS 'Human actor involved.';
-- Set comment to column: "actor_service_identity_id" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."actor_service_identity_id" IS 'Service or device actor involved.';
-- Set comment to column: "source_ip_hash" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."source_ip_hash" IS 'Hash of source IP where retained.';
-- Set comment to column: "user_agent_hash" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."user_agent_hash" IS 'Hash of user agent where retained.';
-- Set comment to column: "request_fingerprint_hash" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."request_fingerprint_hash" IS 'Hash of request fingerprint where retained.';
-- Set comment to column: "incident_record_id" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."incident_record_id" IS 'Related incident, where material.';
-- Set comment to column: "detected_at" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."detected_at" IS 'Timestamp when event was detected.';
-- Set comment to column: "recorded_at" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."recorded_at" IS 'Timestamp when event was recorded.';
-- Set comment to column: "resolved_at" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."resolved_at" IS 'Timestamp when security event was resolved or closed.';
-- Set comment to column: "resolved_by_user_id" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."resolved_by_user_id" IS 'User who resolved or reviewed the event.';
-- Set comment to column: "resolution_reason_code" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."resolution_reason_code" IS 'Controlled resolution reason.';
-- Set comment to column: "correlation_id" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_service_identity_id" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."created_by_service_identity_id" IS 'Service identity that wrote the security event.';
-- Set comment to column: "row_version" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."row_version" IS 'Optimistic concurrency version if status can change.';
-- Create enum type "controlled_code_status_enum"
CREATE TYPE "config"."controlled_code_status_enum" AS ENUM ('DRAFT', 'ACTIVE', 'SUSPENDED', 'DEPRECATED', 'RETIRED');
-- Create enum type "feature_flag_status_enum"
CREATE TYPE "config"."feature_flag_status_enum" AS ENUM ('DRAFT', 'ACTIVE', 'SUSPENDED', 'EXPIRED', 'RETIRED');
-- Create enum type "rate_limit_enforcement_mode_enum"
CREATE TYPE "config"."rate_limit_enforcement_mode_enum" AS ENUM ('MONITOR_ONLY', 'ENFORCE', 'BLOCK', 'CHALLENGE', 'DISABLED');
-- Create enum type "rate_limit_policy_status_enum"
CREATE TYPE "config"."rate_limit_policy_status_enum" AS ENUM ('DRAFT', 'ACTIVE', 'SUSPENDED', 'RETIRED');
-- Create enum type "rate_limit_scope_type_enum"
CREATE TYPE "config"."rate_limit_scope_type_enum" AS ENUM ('PUBLIC_LOOKUP', 'PAYMENT_CREATE', 'PROVIDER_CALLBACK', 'GATE_CONSUME', 'ADMIN_API', 'SUPPORT_TOOL', 'EVIDENCE_ACCESS', 'SERVICE_TO_SERVICE', 'MERCHANT_USER', 'DEVICE', 'CUSTOM');
-- Create enum type "system_parameter_status_enum"
CREATE TYPE "config"."system_parameter_status_enum" AS ENUM ('DRAFT', 'ACTIVE', 'SUSPENDED', 'SUPERSEDED', 'RETIRED');
-- Create enum type "system_parameter_type_enum"
CREATE TYPE "config"."system_parameter_type_enum" AS ENUM ('TEXT', 'NUMERIC', 'BOOLEAN', 'JSON_REFERENCE');
-- Create enum type "ttl_expiry_action_enum"
CREATE TYPE "config"."ttl_expiry_action_enum" AS ENUM ('EXPIRE_RECORD', 'INVALIDATE_RECORD', 'RELEASE_RESERVATION', 'REQUIRE_RECHECK', 'BLOCK_USE', 'PURGE_OR_ARCHIVE', 'NOTIFY_ONLY', 'CUSTOM_WORKFLOW');
-- Create enum type "ttl_policy_status_enum"
CREATE TYPE "config"."ttl_policy_status_enum" AS ENUM ('DRAFT', 'ACTIVE', 'SUSPENDED', 'RETIRED');
-- Create enum type "ttl_scope_type_enum"
CREATE TYPE "config"."ttl_scope_type_enum" AS ENUM ('TARIFF_SNAPSHOT', 'PAYMENT_ATTEMPT', 'PROVIDER_SESSION', 'COUPON_RESERVATION', 'STATUTORY_DISCOUNT_VALIDATION', 'SESSION_LOOKUP_CACHE', 'EXIT_AUTHORIZATION', 'PROVIDER_CALLBACK_REPLAY_WINDOW', 'EVIDENCE_RETENTION', 'OUTBOX_RETRY', 'CUSTOM');
-- Create "controlled_code_sets" table
CREATE TABLE "config"."controlled_code_sets" (
  "controlled_code_set_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "code_set_name" character varying(96) NOT NULL,
  "code_value" character varying(96) NOT NULL,
  "code_label" character varying(128) NOT NULL,
  "code_description" text NULL,
  "code_domain" character varying(64) NOT NULL,
  "code_status" "config"."controlled_code_status_enum" NOT NULL,
  "sort_order" integer NULL,
  "requires_comment" boolean NOT NULL DEFAULT false,
  "requires_approval" boolean NOT NULL DEFAULT false,
  "is_sensitive" boolean NOT NULL DEFAULT false,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_controlled_code_sets" PRIMARY KEY ("controlled_code_set_id"),
  CONSTRAINT "uq_controlled_code_sets__set_value_domain" UNIQUE ("code_set_name", "code_value", "code_domain")
);
-- Create index "ix_controlled_code_sets__code_status" to table: "controlled_code_sets"
CREATE INDEX "ix_controlled_code_sets__code_status" ON "config"."controlled_code_sets" ("code_status");
-- Set comment to table: "controlled_code_sets"
COMMENT ON TABLE "config"."controlled_code_sets" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "controlled_code_set_id" on table: "controlled_code_sets"
COMMENT ON COLUMN "config"."controlled_code_sets"."controlled_code_set_id" IS 'Canonical identifier of the controlled code.';
-- Set comment to column: "code_set_name" on table: "controlled_code_sets"
COMMENT ON COLUMN "config"."controlled_code_sets"."code_set_name" IS 'Name of the code set.';
-- Set comment to column: "code_value" on table: "controlled_code_sets"
COMMENT ON COLUMN "config"."controlled_code_sets"."code_value" IS 'Controlled code value.';
-- Set comment to column: "code_label" on table: "controlled_code_sets"
COMMENT ON COLUMN "config"."controlled_code_sets"."code_label" IS 'Human-readable label.';
-- Set comment to column: "code_description" on table: "controlled_code_sets"
COMMENT ON COLUMN "config"."controlled_code_sets"."code_description" IS 'Description of code meaning and use.';
-- Set comment to column: "code_domain" on table: "controlled_code_sets"
COMMENT ON COLUMN "config"."controlled_code_sets"."code_domain" IS 'Domain where code primarily applies.';
-- Set comment to column: "code_status" on table: "controlled_code_sets"
COMMENT ON COLUMN "config"."controlled_code_sets"."code_status" IS 'Code lifecycle status.';
-- Set comment to column: "sort_order" on table: "controlled_code_sets"
COMMENT ON COLUMN "config"."controlled_code_sets"."sort_order" IS 'Optional display or evaluation order.';
-- Set comment to column: "requires_comment" on table: "controlled_code_sets"
COMMENT ON COLUMN "config"."controlled_code_sets"."requires_comment" IS 'Indicates whether use of the code requires a note.';
-- Set comment to column: "requires_approval" on table: "controlled_code_sets"
COMMENT ON COLUMN "config"."controlled_code_sets"."requires_approval" IS 'Indicates whether use of the code requires approval.';
-- Set comment to column: "is_sensitive" on table: "controlled_code_sets"
COMMENT ON COLUMN "config"."controlled_code_sets"."is_sensitive" IS 'Indicates whether the code is sensitive or restricted in use.';
-- Set comment to column: "effective_from" on table: "controlled_code_sets"
COMMENT ON COLUMN "config"."controlled_code_sets"."effective_from" IS 'Start of code effectiveness.';
-- Set comment to column: "effective_to" on table: "controlled_code_sets"
COMMENT ON COLUMN "config"."controlled_code_sets"."effective_to" IS 'End of code effectiveness.';
-- Set comment to column: "created_at" on table: "controlled_code_sets"
COMMENT ON COLUMN "config"."controlled_code_sets"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "controlled_code_sets"
COMMENT ON COLUMN "config"."controlled_code_sets"."created_by_user_id" IS 'User who created the code.';
-- Set comment to column: "created_by_service_identity_id" on table: "controlled_code_sets"
COMMENT ON COLUMN "config"."controlled_code_sets"."created_by_service_identity_id" IS 'Service identity that created the code.';
-- Set comment to column: "updated_at" on table: "controlled_code_sets"
COMMENT ON COLUMN "config"."controlled_code_sets"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "controlled_code_sets"
COMMENT ON COLUMN "config"."controlled_code_sets"."updated_by_user_id" IS 'User who last updated the code.';
-- Set comment to column: "updated_by_service_identity_id" on table: "controlled_code_sets"
COMMENT ON COLUMN "config"."controlled_code_sets"."updated_by_service_identity_id" IS 'Service identity that last updated the code.';
-- Set comment to column: "row_version" on table: "controlled_code_sets"
COMMENT ON COLUMN "config"."controlled_code_sets"."row_version" IS 'Optimistic concurrency version.';
-- Create "feature_flags" table
CREATE TABLE "config"."feature_flags" (
  "feature_flag_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "flag_code" character varying(96) NOT NULL,
  "flag_name" character varying(128) NOT NULL,
  "flag_description" text NULL,
  "flag_domain" character varying(64) NOT NULL,
  "flag_status" "config"."feature_flag_status_enum" NOT NULL,
  "enabled" boolean NOT NULL DEFAULT false,
  "environment_code" character varying(32) NULL,
  "site_group_id" uuid NULL,
  "site_id" uuid NULL,
  "merchant_id" uuid NULL,
  "payment_rail_id" uuid NULL,
  "service_identity_id" uuid NULL,
  "requires_approval" boolean NOT NULL DEFAULT false,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "approved_at" timestamptz NULL,
  "approved_by_user_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_feature_flags" PRIMARY KEY ("feature_flag_id")
);
-- Create index "ix_feature_flags__merchant_id" to table: "feature_flags"
CREATE INDEX "ix_feature_flags__merchant_id" ON "config"."feature_flags" ("merchant_id");
-- Create index "ix_feature_flags__site_group_id" to table: "feature_flags"
CREATE INDEX "ix_feature_flags__site_group_id" ON "config"."feature_flags" ("site_group_id");
-- Create index "ix_feature_flags__site_id" to table: "feature_flags"
CREATE INDEX "ix_feature_flags__site_id" ON "config"."feature_flags" ("site_id");
-- Create index "ux_feature_flags__scoped_flag" to table: "feature_flags"
CREATE UNIQUE INDEX "ux_feature_flags__scoped_flag" ON "config"."feature_flags" ("flag_code", "environment_code", (COALESCE(site_group_id, '00000000-0000-0000-0000-000000000000'::uuid)), (COALESCE(site_id, '00000000-0000-0000-0000-000000000000'::uuid)), (COALESCE(merchant_id, '00000000-0000-0000-0000-000000000000'::uuid)), (COALESCE(payment_rail_id, '00000000-0000-0000-0000-000000000000'::uuid)), (COALESCE(service_identity_id, '00000000-0000-0000-0000-000000000000'::uuid)));
-- Set comment to table: "feature_flags"
COMMENT ON TABLE "config"."feature_flags" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "feature_flag_id" on table: "feature_flags"
COMMENT ON COLUMN "config"."feature_flags"."feature_flag_id" IS 'Canonical identifier of the feature flag.';
-- Set comment to column: "flag_code" on table: "feature_flags"
COMMENT ON COLUMN "config"."feature_flags"."flag_code" IS 'Stable feature flag code.';
-- Set comment to column: "flag_name" on table: "feature_flags"
COMMENT ON COLUMN "config"."feature_flags"."flag_name" IS 'Human-readable flag name.';
-- Set comment to column: "flag_description" on table: "feature_flags"
COMMENT ON COLUMN "config"."feature_flags"."flag_description" IS 'Description of flag purpose and effect.';
-- Set comment to column: "flag_domain" on table: "feature_flags"
COMMENT ON COLUMN "config"."feature_flags"."flag_domain" IS 'Domain or service area where flag applies.';
-- Set comment to column: "flag_status" on table: "feature_flags"
COMMENT ON COLUMN "config"."feature_flags"."flag_status" IS 'Flag lifecycle status.';
-- Set comment to column: "enabled" on table: "feature_flags"
COMMENT ON COLUMN "config"."feature_flags"."enabled" IS 'Current enabled state.';
-- Set comment to column: "environment_code" on table: "feature_flags"
COMMENT ON COLUMN "config"."feature_flags"."environment_code" IS 'Environment where the flag applies.';
-- Set comment to column: "site_group_id" on table: "feature_flags"
COMMENT ON COLUMN "config"."feature_flags"."site_group_id" IS 'Site group scope, where applicable.';
-- Set comment to column: "site_id" on table: "feature_flags"
COMMENT ON COLUMN "config"."feature_flags"."site_id" IS 'Site scope, where applicable.';
-- Set comment to column: "merchant_id" on table: "feature_flags"
COMMENT ON COLUMN "config"."feature_flags"."merchant_id" IS 'Merchant scope, where applicable.';
-- Set comment to column: "payment_rail_id" on table: "feature_flags"
COMMENT ON COLUMN "config"."feature_flags"."payment_rail_id" IS 'Payment rail scope, where applicable.';
-- Set comment to column: "service_identity_id" on table: "feature_flags"
COMMENT ON COLUMN "config"."feature_flags"."service_identity_id" IS 'Service identity scope, where applicable.';
-- Set comment to column: "requires_approval" on table: "feature_flags"
COMMENT ON COLUMN "config"."feature_flags"."requires_approval" IS 'Indicates whether changes require approval.';
-- Set comment to column: "effective_from" on table: "feature_flags"
COMMENT ON COLUMN "config"."feature_flags"."effective_from" IS 'Start of flag effectiveness.';
-- Set comment to column: "effective_to" on table: "feature_flags"
COMMENT ON COLUMN "config"."feature_flags"."effective_to" IS 'End of flag effectiveness.';
-- Set comment to column: "approved_at" on table: "feature_flags"
COMMENT ON COLUMN "config"."feature_flags"."approved_at" IS 'Approval timestamp, where required.';
-- Set comment to column: "approved_by_user_id" on table: "feature_flags"
COMMENT ON COLUMN "config"."feature_flags"."approved_by_user_id" IS 'User who approved the flag.';
-- Set comment to column: "created_at" on table: "feature_flags"
COMMENT ON COLUMN "config"."feature_flags"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "feature_flags"
COMMENT ON COLUMN "config"."feature_flags"."created_by_user_id" IS 'User who created the flag.';
-- Set comment to column: "created_by_service_identity_id" on table: "feature_flags"
COMMENT ON COLUMN "config"."feature_flags"."created_by_service_identity_id" IS 'Service identity that created the flag.';
-- Set comment to column: "updated_at" on table: "feature_flags"
COMMENT ON COLUMN "config"."feature_flags"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "feature_flags"
COMMENT ON COLUMN "config"."feature_flags"."updated_by_user_id" IS 'User who last updated the flag.';
-- Set comment to column: "updated_by_service_identity_id" on table: "feature_flags"
COMMENT ON COLUMN "config"."feature_flags"."updated_by_service_identity_id" IS 'Service identity that last updated the flag.';
-- Set comment to column: "row_version" on table: "feature_flags"
COMMENT ON COLUMN "config"."feature_flags"."row_version" IS 'Optimistic concurrency version.';
-- Create "rate_limit_policies" table
CREATE TABLE "config"."rate_limit_policies" (
  "rate_limit_policy_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "policy_code" character varying(96) NOT NULL,
  "policy_name" character varying(128) NOT NULL,
  "policy_description" text NULL,
  "policy_domain" character varying(64) NOT NULL,
  "scope_type" "config"."rate_limit_scope_type_enum" NOT NULL,
  "window_seconds" integer NOT NULL,
  "max_requests" integer NOT NULL,
  "burst_limit" integer NULL,
  "penalty_seconds" integer NULL,
  "policy_status" "config"."rate_limit_policy_status_enum" NOT NULL,
  "enforcement_mode" "config"."rate_limit_enforcement_mode_enum" NOT NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_rate_limit_policies" PRIMARY KEY ("rate_limit_policy_id"),
  CONSTRAINT "uq_rate_limit_policies__policy_code" UNIQUE ("policy_code")
);
-- Create index "ix_rate_limit_policies__policy_status" to table: "rate_limit_policies"
CREATE INDEX "ix_rate_limit_policies__policy_status" ON "config"."rate_limit_policies" ("policy_status");
-- Set comment to table: "rate_limit_policies"
COMMENT ON TABLE "config"."rate_limit_policies" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "rate_limit_policy_id" on table: "rate_limit_policies"
COMMENT ON COLUMN "config"."rate_limit_policies"."rate_limit_policy_id" IS 'Canonical identifier of the rate-limit policy.';
-- Set comment to column: "policy_code" on table: "rate_limit_policies"
COMMENT ON COLUMN "config"."rate_limit_policies"."policy_code" IS 'Stable policy code.';
-- Set comment to column: "policy_name" on table: "rate_limit_policies"
COMMENT ON COLUMN "config"."rate_limit_policies"."policy_name" IS 'Human-readable policy name.';
-- Set comment to column: "policy_description" on table: "rate_limit_policies"
COMMENT ON COLUMN "config"."rate_limit_policies"."policy_description" IS 'Description of policy purpose.';
-- Set comment to column: "policy_domain" on table: "rate_limit_policies"
COMMENT ON COLUMN "config"."rate_limit_policies"."policy_domain" IS 'Domain or service area where policy applies.';
-- Set comment to column: "scope_type" on table: "rate_limit_policies"
COMMENT ON COLUMN "config"."rate_limit_policies"."scope_type" IS 'Scope of the rate limit.';
-- Set comment to column: "window_seconds" on table: "rate_limit_policies"
COMMENT ON COLUMN "config"."rate_limit_policies"."window_seconds" IS 'Rolling or fixed window duration in seconds.';
-- Set comment to column: "max_requests" on table: "rate_limit_policies"
COMMENT ON COLUMN "config"."rate_limit_policies"."max_requests" IS 'Maximum allowed requests in the window.';
-- Set comment to column: "burst_limit" on table: "rate_limit_policies"
COMMENT ON COLUMN "config"."rate_limit_policies"."burst_limit" IS 'Optional burst allowance.';
-- Set comment to column: "penalty_seconds" on table: "rate_limit_policies"
COMMENT ON COLUMN "config"."rate_limit_policies"."penalty_seconds" IS 'Lockout or penalty duration after violation.';
-- Set comment to column: "policy_status" on table: "rate_limit_policies"
COMMENT ON COLUMN "config"."rate_limit_policies"."policy_status" IS 'Policy lifecycle status.';
-- Set comment to column: "enforcement_mode" on table: "rate_limit_policies"
COMMENT ON COLUMN "config"."rate_limit_policies"."enforcement_mode" IS 'Enforcement behavior.';
-- Set comment to column: "effective_from" on table: "rate_limit_policies"
COMMENT ON COLUMN "config"."rate_limit_policies"."effective_from" IS 'Start of policy effectiveness.';
-- Set comment to column: "effective_to" on table: "rate_limit_policies"
COMMENT ON COLUMN "config"."rate_limit_policies"."effective_to" IS 'End of policy effectiveness.';
-- Set comment to column: "created_at" on table: "rate_limit_policies"
COMMENT ON COLUMN "config"."rate_limit_policies"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "rate_limit_policies"
COMMENT ON COLUMN "config"."rate_limit_policies"."created_by_user_id" IS 'User who created the policy.';
-- Set comment to column: "created_by_service_identity_id" on table: "rate_limit_policies"
COMMENT ON COLUMN "config"."rate_limit_policies"."created_by_service_identity_id" IS 'Service identity that created the policy.';
-- Set comment to column: "updated_at" on table: "rate_limit_policies"
COMMENT ON COLUMN "config"."rate_limit_policies"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "rate_limit_policies"
COMMENT ON COLUMN "config"."rate_limit_policies"."updated_by_user_id" IS 'User who last updated the policy.';
-- Set comment to column: "updated_by_service_identity_id" on table: "rate_limit_policies"
COMMENT ON COLUMN "config"."rate_limit_policies"."updated_by_service_identity_id" IS 'Service identity that last updated the policy.';
-- Set comment to column: "row_version" on table: "rate_limit_policies"
COMMENT ON COLUMN "config"."rate_limit_policies"."row_version" IS 'Optimistic concurrency version.';
-- Create "system_parameters" table
CREATE TABLE "config"."system_parameters" (
  "system_parameter_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "parameter_code" character varying(96) NOT NULL,
  "parameter_name" character varying(128) NOT NULL,
  "parameter_description" text NULL,
  "parameter_domain" character varying(64) NOT NULL,
  "parameter_type" "config"."system_parameter_type_enum" NOT NULL,
  "value_text" text NULL,
  "value_numeric" numeric(18,4) NULL,
  "value_boolean" boolean NULL,
  "value_json_ref" character varying(256) NULL,
  "parameter_status" "config"."system_parameter_status_enum" NOT NULL,
  "requires_approval" boolean NOT NULL DEFAULT false,
  "is_sensitive" boolean NOT NULL DEFAULT false,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "approved_at" timestamptz NULL,
  "approved_by_user_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_system_parameters" PRIMARY KEY ("system_parameter_id")
);
-- Create index "ix_system_parameters__approved_at" to table: "system_parameters"
CREATE INDEX "ix_system_parameters__approved_at" ON "config"."system_parameters" ("approved_at");
-- Create index "ix_system_parameters__parameter_status" to table: "system_parameters"
CREATE INDEX "ix_system_parameters__parameter_status" ON "config"."system_parameters" ("parameter_status");
-- Set comment to table: "system_parameters"
COMMENT ON TABLE "config"."system_parameters" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "system_parameter_id" on table: "system_parameters"
COMMENT ON COLUMN "config"."system_parameters"."system_parameter_id" IS 'Canonical identifier of the system parameter.';
-- Set comment to column: "parameter_code" on table: "system_parameters"
COMMENT ON COLUMN "config"."system_parameters"."parameter_code" IS 'Stable parameter code.';
-- Set comment to column: "parameter_name" on table: "system_parameters"
COMMENT ON COLUMN "config"."system_parameters"."parameter_name" IS 'Human-readable parameter name.';
-- Set comment to column: "parameter_description" on table: "system_parameters"
COMMENT ON COLUMN "config"."system_parameters"."parameter_description" IS 'Description of the parameter and intended use.';
-- Set comment to column: "parameter_domain" on table: "system_parameters"
COMMENT ON COLUMN "config"."system_parameters"."parameter_domain" IS 'Domain or service area where parameter applies.';
-- Set comment to column: "parameter_type" on table: "system_parameters"
COMMENT ON COLUMN "config"."system_parameters"."parameter_type" IS 'Data type of the parameter value.';
-- Set comment to column: "value_text" on table: "system_parameters"
COMMENT ON COLUMN "config"."system_parameters"."value_text" IS 'Text parameter value.';
-- Set comment to column: "value_numeric" on table: "system_parameters"
COMMENT ON COLUMN "config"."system_parameters"."value_numeric" IS 'Numeric parameter value.';
-- Set comment to column: "value_boolean" on table: "system_parameters"
COMMENT ON COLUMN "config"."system_parameters"."value_boolean" IS 'Boolean parameter value.';
-- Set comment to column: "value_json_ref" on table: "system_parameters"
COMMENT ON COLUMN "config"."system_parameters"."value_json_ref" IS 'Reference to structured configuration if stored externally.';
-- Set comment to column: "parameter_status" on table: "system_parameters"
COMMENT ON COLUMN "config"."system_parameters"."parameter_status" IS 'Parameter lifecycle status.';
-- Set comment to column: "requires_approval" on table: "system_parameters"
COMMENT ON COLUMN "config"."system_parameters"."requires_approval" IS 'Indicates whether changes require approval.';
-- Set comment to column: "is_sensitive" on table: "system_parameters"
COMMENT ON COLUMN "config"."system_parameters"."is_sensitive" IS 'Indicates sensitive configuration metadata. Must not mean secret storage.';
-- Set comment to column: "effective_from" on table: "system_parameters"
COMMENT ON COLUMN "config"."system_parameters"."effective_from" IS 'Start of parameter effectiveness.';
-- Set comment to column: "effective_to" on table: "system_parameters"
COMMENT ON COLUMN "config"."system_parameters"."effective_to" IS 'End of parameter effectiveness.';
-- Set comment to column: "approved_at" on table: "system_parameters"
COMMENT ON COLUMN "config"."system_parameters"."approved_at" IS 'Approval timestamp, where required.';
-- Set comment to column: "approved_by_user_id" on table: "system_parameters"
COMMENT ON COLUMN "config"."system_parameters"."approved_by_user_id" IS 'User who approved the parameter.';
-- Set comment to column: "created_at" on table: "system_parameters"
COMMENT ON COLUMN "config"."system_parameters"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "system_parameters"
COMMENT ON COLUMN "config"."system_parameters"."created_by_user_id" IS 'User who created the parameter.';
-- Set comment to column: "created_by_service_identity_id" on table: "system_parameters"
COMMENT ON COLUMN "config"."system_parameters"."created_by_service_identity_id" IS 'Service identity that created the parameter.';
-- Set comment to column: "updated_at" on table: "system_parameters"
COMMENT ON COLUMN "config"."system_parameters"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "system_parameters"
COMMENT ON COLUMN "config"."system_parameters"."updated_by_user_id" IS 'User who last updated the parameter.';
-- Set comment to column: "updated_by_service_identity_id" on table: "system_parameters"
COMMENT ON COLUMN "config"."system_parameters"."updated_by_service_identity_id" IS 'Service identity that last updated the parameter.';
-- Set comment to column: "row_version" on table: "system_parameters"
COMMENT ON COLUMN "config"."system_parameters"."row_version" IS 'Optimistic concurrency version.';
-- Create "ttl_policies" table
CREATE TABLE "config"."ttl_policies" (
  "ttl_policy_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "policy_code" character varying(96) NOT NULL,
  "policy_name" character varying(128) NOT NULL,
  "policy_description" text NULL,
  "policy_domain" character varying(64) NOT NULL,
  "ttl_scope_type" "config"."ttl_scope_type_enum" NOT NULL,
  "ttl_seconds" integer NOT NULL,
  "grace_period_seconds" integer NULL,
  "expiry_action" "config"."ttl_expiry_action_enum" NOT NULL,
  "policy_status" "config"."ttl_policy_status_enum" NOT NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_ttl_policies" PRIMARY KEY ("ttl_policy_id"),
  CONSTRAINT "uq_ttl_policies__policy_code" UNIQUE ("policy_code")
);
-- Create index "ix_ttl_policies__policy_status" to table: "ttl_policies"
CREATE INDEX "ix_ttl_policies__policy_status" ON "config"."ttl_policies" ("policy_status");
-- Set comment to table: "ttl_policies"
COMMENT ON TABLE "config"."ttl_policies" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "ttl_policy_id" on table: "ttl_policies"
COMMENT ON COLUMN "config"."ttl_policies"."ttl_policy_id" IS 'Canonical identifier of the TTL policy.';
-- Set comment to column: "policy_code" on table: "ttl_policies"
COMMENT ON COLUMN "config"."ttl_policies"."policy_code" IS 'Stable TTL policy code.';
-- Set comment to column: "policy_name" on table: "ttl_policies"
COMMENT ON COLUMN "config"."ttl_policies"."policy_name" IS 'Human-readable policy name.';
-- Set comment to column: "policy_description" on table: "ttl_policies"
COMMENT ON COLUMN "config"."ttl_policies"."policy_description" IS 'Description of policy purpose.';
-- Set comment to column: "policy_domain" on table: "ttl_policies"
COMMENT ON COLUMN "config"."ttl_policies"."policy_domain" IS 'Domain or workflow where policy applies.';
-- Set comment to column: "ttl_scope_type" on table: "ttl_policies"
COMMENT ON COLUMN "config"."ttl_policies"."ttl_scope_type" IS 'Expiry scope.';
-- Set comment to column: "ttl_seconds" on table: "ttl_policies"
COMMENT ON COLUMN "config"."ttl_policies"."ttl_seconds" IS 'TTL duration in seconds.';
-- Set comment to column: "grace_period_seconds" on table: "ttl_policies"
COMMENT ON COLUMN "config"."ttl_policies"."grace_period_seconds" IS 'Optional grace period for support or cleanup, not validity extension unless domain allows.';
-- Set comment to column: "expiry_action" on table: "ttl_policies"
COMMENT ON COLUMN "config"."ttl_policies"."expiry_action" IS 'Action expected when TTL expires.';
-- Set comment to column: "policy_status" on table: "ttl_policies"
COMMENT ON COLUMN "config"."ttl_policies"."policy_status" IS 'TTL policy lifecycle status.';
-- Set comment to column: "effective_from" on table: "ttl_policies"
COMMENT ON COLUMN "config"."ttl_policies"."effective_from" IS 'Start of policy effectiveness.';
-- Set comment to column: "effective_to" on table: "ttl_policies"
COMMENT ON COLUMN "config"."ttl_policies"."effective_to" IS 'End of policy effectiveness.';
-- Set comment to column: "created_at" on table: "ttl_policies"
COMMENT ON COLUMN "config"."ttl_policies"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "ttl_policies"
COMMENT ON COLUMN "config"."ttl_policies"."created_by_user_id" IS 'User who created the policy.';
-- Set comment to column: "created_by_service_identity_id" on table: "ttl_policies"
COMMENT ON COLUMN "config"."ttl_policies"."created_by_service_identity_id" IS 'Service identity that created the policy.';
-- Set comment to column: "updated_at" on table: "ttl_policies"
COMMENT ON COLUMN "config"."ttl_policies"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "ttl_policies"
COMMENT ON COLUMN "config"."ttl_policies"."updated_by_user_id" IS 'User who last updated the policy.';
-- Set comment to column: "updated_by_service_identity_id" on table: "ttl_policies"
COMMENT ON COLUMN "config"."ttl_policies"."updated_by_service_identity_id" IS 'Service identity that last updated the policy.';
-- Set comment to column: "row_version" on table: "ttl_policies"
COMMENT ON COLUMN "config"."ttl_policies"."row_version" IS 'Optimistic concurrency version.';
-- Create enum type "exit_authorization_status_enum"
CREATE TYPE "core"."exit_authorization_status_enum" AS ENUM ('ISSUED', 'EXPIRED', 'INVALIDATED');
-- Create enum type "parking_session_status_enum"
CREATE TYPE "core"."parking_session_status_enum" AS ENUM ('ACTIVE', 'CLOSED', 'EXPIRED', 'INVALIDATED');
-- Create enum type "payment_attempt_status_enum"
CREATE TYPE "core"."payment_attempt_status_enum" AS ENUM ('REQUESTED', 'PENDING_PROVIDER', 'PENDING_FINALIZATION', 'CONFIRMED', 'FAILED', 'EXPIRED', 'CANCELLED');
-- Create enum type "payment_confirmation_status_enum"
CREATE TYPE "core"."payment_confirmation_status_enum" AS ENUM ('RECORDED', 'VOIDED');
-- Create enum type "tariff_snapshot_status_enum"
CREATE TYPE "core"."tariff_snapshot_status_enum" AS ENUM ('ACTIVE', 'CONSUMED', 'EXPIRED', 'SUPERSEDED', 'INVALIDATED');
-- Create "create_or_reuse_payment_attempt" function
CREATE FUNCTION "core"."create_or_reuse_payment_attempt" () RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'core.create_or_reuse_payment_attempt is a v1.2 routine placeholder and must be implemented before production use'; END; $$;
-- Create "issue_exit_authorization" function
CREATE FUNCTION "core"."issue_exit_authorization" () RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'core.issue_exit_authorization is a v1.2 routine placeholder and must be implemented before production use'; END; $$;
-- Create "record_payment_confirmation" function
CREATE FUNCTION "core"."record_payment_confirmation" () RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'core.record_payment_confirmation is a v1.2 routine placeholder and must be implemented before production use'; END; $$;
-- Create "exit_authorizations" table
CREATE TABLE "core"."exit_authorizations" (
  "exit_authorization_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "parking_session_id" uuid NOT NULL,
  "payment_attempt_id" uuid NOT NULL,
  "payment_confirmation_id" uuid NOT NULL,
  "authorization_token_hash" character(64) NOT NULL,
  "authorization_status" "core"."exit_authorization_status_enum" NOT NULL,
  "issued_at" timestamptz NOT NULL,
  "expires_at" timestamptz NOT NULL,
  "invalidated_at" timestamptz NULL,
  "invalidation_reason_code" character varying(64) NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_exit_authorizations" PRIMARY KEY ("exit_authorization_id")
);
-- Create index "ix_exit_authorizations__authorization_status" to table: "exit_authorizations"
CREATE INDEX "ix_exit_authorizations__authorization_status" ON "core"."exit_authorizations" ("authorization_status");
-- Create index "ix_exit_authorizations__correlation_id" to table: "exit_authorizations"
CREATE INDEX "ix_exit_authorizations__correlation_id" ON "core"."exit_authorizations" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_exit_authorizations__parking_session_id" to table: "exit_authorizations"
CREATE INDEX "ix_exit_authorizations__parking_session_id" ON "core"."exit_authorizations" ("parking_session_id");
-- Create index "ix_exit_authorizations__payment_attempt_id" to table: "exit_authorizations"
CREATE INDEX "ix_exit_authorizations__payment_attempt_id" ON "core"."exit_authorizations" ("payment_attempt_id");
-- Create index "ix_exit_authorizations__payment_confirmation_id" to table: "exit_authorizations"
CREATE INDEX "ix_exit_authorizations__payment_confirmation_id" ON "core"."exit_authorizations" ("payment_confirmation_id");
-- Create index "ux_exit_authorizations__active_by_session" to table: "exit_authorizations"
CREATE UNIQUE INDEX "ux_exit_authorizations__active_by_session" ON "core"."exit_authorizations" ("parking_session_id") WHERE (authorization_status = 'ISSUED'::core.exit_authorization_status_enum);
-- Set comment to table: "exit_authorizations"
COMMENT ON TABLE "core"."exit_authorizations" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "exit_authorization_id" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."exit_authorization_id" IS 'Canonical identifier of the exit authorization.';
-- Set comment to column: "parking_session_id" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."parking_session_id" IS 'Parking session for which exit is authorized.';
-- Set comment to column: "payment_attempt_id" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."payment_attempt_id" IS 'Confirmed payment attempt that established financial control state.';
-- Set comment to column: "payment_confirmation_id" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."payment_confirmation_id" IS 'Canonical payment confirmation supporting issuance.';
-- Set comment to column: "authorization_token_hash" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."authorization_token_hash" IS 'Hash of opaque token used for secure lookup and replay-safe validation.';
-- Set comment to column: "authorization_status" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."authorization_status" IS 'Current validity status of the authorization.';
-- Set comment to column: "issued_at" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."issued_at" IS 'Issuance timestamp.';
-- Set comment to column: "expires_at" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."expires_at" IS 'Expiration boundary for authorization validity.';
-- Set comment to column: "invalidated_at" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."invalidated_at" IS 'Timestamp when authorization was invalidated, if applicable.';
-- Set comment to column: "invalidation_reason_code" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."invalidation_reason_code" IS 'Controlled reason for invalidation.';
-- Set comment to column: "correlation_id" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_service_identity_id" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."created_by_service_identity_id" IS 'Creating service identity.';
-- Set comment to column: "updated_at" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."updated_at" IS 'Last mutation timestamp.';
-- Set comment to column: "updated_by_service_identity_id" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."updated_by_service_identity_id" IS 'Updating service identity.';
-- Set comment to column: "row_version" on table: "exit_authorizations"
COMMENT ON COLUMN "core"."exit_authorizations"."row_version" IS 'Optimistic concurrency version.';
-- Create "parking_sessions" table
CREATE TABLE "core"."parking_sessions" (
  "parking_session_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "site_group_id" uuid NOT NULL,
  "site_id" uuid NOT NULL,
  "vendor_system_id" uuid NOT NULL,
  "vendor_session_ref" character varying(128) NOT NULL,
  "plate_number_hash" character(64) NULL,
  "plate_number_masked" character varying(32) NULL,
  "ticket_number_hash" character(64) NULL,
  "ticket_number_masked" character varying(64) NULL,
  "entry_at" timestamptz NULL,
  "vendor_session_status" character varying(64) NULL,
  "session_status" "core"."parking_session_status_enum" NOT NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_parking_sessions" PRIMARY KEY ("parking_session_id")
);
-- Create index "ix_parking_sessions__correlation_id" to table: "parking_sessions"
CREATE INDEX "ix_parking_sessions__correlation_id" ON "core"."parking_sessions" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_parking_sessions__site_group_id" to table: "parking_sessions"
CREATE INDEX "ix_parking_sessions__site_group_id" ON "core"."parking_sessions" ("site_group_id");
-- Create index "ix_parking_sessions__site_id" to table: "parking_sessions"
CREATE INDEX "ix_parking_sessions__site_id" ON "core"."parking_sessions" ("site_id");
-- Create index "ix_parking_sessions__vendor_session_status" to table: "parking_sessions"
CREATE INDEX "ix_parking_sessions__vendor_session_status" ON "core"."parking_sessions" ("vendor_session_status");
-- Create index "ix_parking_sessions__vendor_system_id" to table: "parking_sessions"
CREATE INDEX "ix_parking_sessions__vendor_system_id" ON "core"."parking_sessions" ("vendor_system_id");
-- Set comment to table: "parking_sessions"
COMMENT ON TABLE "core"."parking_sessions" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "parking_session_id" on table: "parking_sessions"
COMMENT ON COLUMN "core"."parking_sessions"."parking_session_id" IS 'Canonical ExitPass identifier for the parking session.';
-- Set comment to column: "site_group_id" on table: "parking_sessions"
COMMENT ON COLUMN "core"."parking_sessions"."site_group_id" IS 'Site group used for lookup scope and business context.';
-- Set comment to column: "site_id" on table: "parking_sessions"
COMMENT ON COLUMN "core"."parking_sessions"."site_id" IS 'Site where the parking session belongs.';
-- Set comment to column: "vendor_system_id" on table: "parking_sessions"
COMMENT ON COLUMN "core"."parking_sessions"."vendor_system_id" IS 'Vendor PMS that owns the raw parking session lifecycle.';
-- Set comment to column: "vendor_session_ref" on table: "parking_sessions"
COMMENT ON COLUMN "core"."parking_sessions"."vendor_session_ref" IS 'Vendor PMS session reference.';
-- Set comment to column: "plate_number_hash" on table: "parking_sessions"
COMMENT ON COLUMN "core"."parking_sessions"."plate_number_hash" IS 'Hash of normalized plate number for lookup and privacy-aware traceability.';
-- Set comment to column: "plate_number_masked" on table: "parking_sessions"
COMMENT ON COLUMN "core"."parking_sessions"."plate_number_masked" IS 'Masked or partially redacted plate display value.';
-- Set comment to column: "ticket_number_hash" on table: "parking_sessions"
COMMENT ON COLUMN "core"."parking_sessions"."ticket_number_hash" IS 'Hash of normalized ticket number where applicable.';
-- Set comment to column: "ticket_number_masked" on table: "parking_sessions"
COMMENT ON COLUMN "core"."parking_sessions"."ticket_number_masked" IS 'Masked or partially redacted ticket display value.';
-- Set comment to column: "entry_at" on table: "parking_sessions"
COMMENT ON COLUMN "core"."parking_sessions"."entry_at" IS 'Entry timestamp as reported by Vendor PMS.';
-- Set comment to column: "vendor_session_status" on table: "parking_sessions"
COMMENT ON COLUMN "core"."parking_sessions"."vendor_session_status" IS 'Vendor-reported session status for traceability.';
-- Set comment to column: "session_status" on table: "parking_sessions"
COMMENT ON COLUMN "core"."parking_sessions"."session_status" IS 'ExitPass control status for the canonical session reference.';
-- Set comment to column: "correlation_id" on table: "parking_sessions"
COMMENT ON COLUMN "core"."parking_sessions"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "parking_sessions"
COMMENT ON COLUMN "core"."parking_sessions"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_service_identity_id" on table: "parking_sessions"
COMMENT ON COLUMN "core"."parking_sessions"."created_by_service_identity_id" IS 'Service identity that created the record.';
-- Set comment to column: "updated_at" on table: "parking_sessions"
COMMENT ON COLUMN "core"."parking_sessions"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_service_identity_id" on table: "parking_sessions"
COMMENT ON COLUMN "core"."parking_sessions"."updated_by_service_identity_id" IS 'Service identity that last updated the record.';
-- Set comment to column: "row_version" on table: "parking_sessions"
COMMENT ON COLUMN "core"."parking_sessions"."row_version" IS 'Optimistic concurrency version.';
-- Create "payment_attempts" table
CREATE TABLE "core"."payment_attempts" (
  "payment_attempt_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "parking_session_id" uuid NOT NULL,
  "tariff_snapshot_id" uuid NOT NULL,
  "idempotency_key" character varying(128) NOT NULL,
  "payment_rail_id" uuid NULL,
  "currency_code" character(3) NOT NULL,
  "amount" numeric(18,2) NOT NULL,
  "attempt_status" "core"."payment_attempt_status_enum" NOT NULL,
  "requested_at" timestamptz NOT NULL,
  "expires_at" timestamptz NOT NULL,
  "finalized_at" timestamptz NULL,
  "failure_reason_code" character varying(64) NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_payment_attempts" PRIMARY KEY ("payment_attempt_id")
);
-- Create index "ix_payment_attempts__attempt_status" to table: "payment_attempts"
CREATE INDEX "ix_payment_attempts__attempt_status" ON "core"."payment_attempts" ("attempt_status");
-- Create index "ix_payment_attempts__correlation_id" to table: "payment_attempts"
CREATE INDEX "ix_payment_attempts__correlation_id" ON "core"."payment_attempts" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_payment_attempts__parking_session_id" to table: "payment_attempts"
CREATE INDEX "ix_payment_attempts__parking_session_id" ON "core"."payment_attempts" ("parking_session_id");
-- Create index "ix_payment_attempts__payment_rail_id" to table: "payment_attempts"
CREATE INDEX "ix_payment_attempts__payment_rail_id" ON "core"."payment_attempts" ("payment_rail_id");
-- Create index "ix_payment_attempts__tariff_snapshot_id" to table: "payment_attempts"
CREATE INDEX "ix_payment_attempts__tariff_snapshot_id" ON "core"."payment_attempts" ("tariff_snapshot_id");
-- Create index "ux_payment_attempts__active_by_session" to table: "payment_attempts"
CREATE UNIQUE INDEX "ux_payment_attempts__active_by_session" ON "core"."payment_attempts" ("parking_session_id") WHERE (attempt_status = ANY (ARRAY['REQUESTED'::core.payment_attempt_status_enum, 'PENDING_PROVIDER'::core.payment_attempt_status_enum, 'PENDING_FINALIZATION'::core.payment_attempt_status_enum]));
-- Set comment to table: "payment_attempts"
COMMENT ON TABLE "core"."payment_attempts" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "payment_attempt_id" on table: "payment_attempts"
COMMENT ON COLUMN "core"."payment_attempts"."payment_attempt_id" IS 'Canonical identifier of the payment attempt.';
-- Set comment to column: "parking_session_id" on table: "payment_attempts"
COMMENT ON COLUMN "core"."payment_attempts"."parking_session_id" IS 'Parking session being paid for.';
-- Set comment to column: "tariff_snapshot_id" on table: "payment_attempts"
COMMENT ON COLUMN "core"."payment_attempts"."tariff_snapshot_id" IS 'Immutable payable basis used by this attempt.';
-- Set comment to column: "idempotency_key" on table: "payment_attempts"
COMMENT ON COLUMN "core"."payment_attempts"."idempotency_key" IS 'Client or service-supplied idempotency key.';
-- Set comment to column: "payment_rail_id" on table: "payment_attempts"
COMMENT ON COLUMN "core"."payment_attempts"."payment_rail_id" IS 'Intended or selected payment rail.';
-- Set comment to column: "currency_code" on table: "payment_attempts"
COMMENT ON COLUMN "core"."payment_attempts"."currency_code" IS 'Currency code.';
-- Set comment to column: "amount" on table: "payment_attempts"
COMMENT ON COLUMN "core"."payment_attempts"."amount" IS 'Amount to be paid, copied from bound tariff snapshot.';
-- Set comment to column: "attempt_status" on table: "payment_attempts"
COMMENT ON COLUMN "core"."payment_attempts"."attempt_status" IS 'Lifecycle state of the payment attempt.';
-- Set comment to column: "requested_at" on table: "payment_attempts"
COMMENT ON COLUMN "core"."payment_attempts"."requested_at" IS 'Timestamp when the attempt was requested.';
-- Set comment to column: "expires_at" on table: "payment_attempts"
COMMENT ON COLUMN "core"."payment_attempts"."expires_at" IS 'Expiry boundary for the payment attempt.';
-- Set comment to column: "finalized_at" on table: "payment_attempts"
COMMENT ON COLUMN "core"."payment_attempts"."finalized_at" IS 'Timestamp when attempt reached terminal finality.';
-- Set comment to column: "failure_reason_code" on table: "payment_attempts"
COMMENT ON COLUMN "core"."payment_attempts"."failure_reason_code" IS 'Controlled failure reason.';
-- Set comment to column: "correlation_id" on table: "payment_attempts"
COMMENT ON COLUMN "core"."payment_attempts"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "payment_attempts"
COMMENT ON COLUMN "core"."payment_attempts"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_service_identity_id" on table: "payment_attempts"
COMMENT ON COLUMN "core"."payment_attempts"."created_by_service_identity_id" IS 'Service identity that created the attempt.';
-- Set comment to column: "updated_at" on table: "payment_attempts"
COMMENT ON COLUMN "core"."payment_attempts"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_service_identity_id" on table: "payment_attempts"
COMMENT ON COLUMN "core"."payment_attempts"."updated_by_service_identity_id" IS 'Service identity that last updated the record.';
-- Set comment to column: "row_version" on table: "payment_attempts"
COMMENT ON COLUMN "core"."payment_attempts"."row_version" IS 'Optimistic concurrency version.';
-- Create "payment_confirmations" table
CREATE TABLE "core"."payment_confirmations" (
  "payment_confirmation_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "payment_attempt_id" uuid NOT NULL,
  "provider_outcome_id" uuid NULL,
  "payment_rail_id" uuid NULL,
  "provider_transaction_ref" character varying(128) NULL,
  "currency_code" character(3) NOT NULL,
  "confirmed_amount" numeric(18,2) NOT NULL,
  "confirmation_status" "core"."payment_confirmation_status_enum" NOT NULL,
  "verified_at" timestamptz NOT NULL,
  "confirmed_at" timestamptz NOT NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  CONSTRAINT "pk_payment_confirmations" PRIMARY KEY ("payment_confirmation_id")
);
-- Create index "ix_payment_confirmations__confirmation_status" to table: "payment_confirmations"
CREATE INDEX "ix_payment_confirmations__confirmation_status" ON "core"."payment_confirmations" ("confirmation_status");
-- Create index "ix_payment_confirmations__correlation_id" to table: "payment_confirmations"
CREATE INDEX "ix_payment_confirmations__correlation_id" ON "core"."payment_confirmations" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_payment_confirmations__payment_attempt_id" to table: "payment_confirmations"
CREATE INDEX "ix_payment_confirmations__payment_attempt_id" ON "core"."payment_confirmations" ("payment_attempt_id");
-- Create index "ix_payment_confirmations__payment_rail_id" to table: "payment_confirmations"
CREATE INDEX "ix_payment_confirmations__payment_rail_id" ON "core"."payment_confirmations" ("payment_rail_id");
-- Create index "ix_payment_confirmations__provider_outcome_id" to table: "payment_confirmations"
CREATE INDEX "ix_payment_confirmations__provider_outcome_id" ON "core"."payment_confirmations" ("provider_outcome_id");
-- Create index "ux_payment_confirmations__provider_outcome" to table: "payment_confirmations"
CREATE UNIQUE INDEX "ux_payment_confirmations__provider_outcome" ON "core"."payment_confirmations" ("provider_outcome_id") WHERE (provider_outcome_id IS NOT NULL);
-- Create index "ux_payment_confirmations__provider_transaction_ref" to table: "payment_confirmations"
CREATE UNIQUE INDEX "ux_payment_confirmations__provider_transaction_ref" ON "core"."payment_confirmations" ("payment_rail_id", "provider_transaction_ref") WHERE (provider_transaction_ref IS NOT NULL);
-- Set comment to table: "payment_confirmations"
COMMENT ON TABLE "core"."payment_confirmations" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "payment_confirmation_id" on table: "payment_confirmations"
COMMENT ON COLUMN "core"."payment_confirmations"."payment_confirmation_id" IS 'Canonical identifier of the payment confirmation.';
-- Set comment to column: "payment_attempt_id" on table: "payment_confirmations"
COMMENT ON COLUMN "core"."payment_confirmations"."payment_attempt_id" IS 'Payment attempt confirmed by this record.';
-- Set comment to column: "provider_outcome_id" on table: "payment_confirmations"
COMMENT ON COLUMN "core"."payment_confirmations"."provider_outcome_id" IS 'Verified provider outcome that supported confirmation.';
-- Set comment to column: "payment_rail_id" on table: "payment_confirmations"
COMMENT ON COLUMN "core"."payment_confirmations"."payment_rail_id" IS 'Rail through which the payment was completed.';
-- Set comment to column: "provider_transaction_ref" on table: "payment_confirmations"
COMMENT ON COLUMN "core"."payment_confirmations"."provider_transaction_ref" IS 'Provider transaction reference used for traceability.';
-- Set comment to column: "currency_code" on table: "payment_confirmations"
COMMENT ON COLUMN "core"."payment_confirmations"."currency_code" IS 'Currency code.';
-- Set comment to column: "confirmed_amount" on table: "payment_confirmations"
COMMENT ON COLUMN "core"."payment_confirmations"."confirmed_amount" IS 'Amount confirmed as paid.';
-- Set comment to column: "confirmation_status" on table: "payment_confirmations"
COMMENT ON COLUMN "core"."payment_confirmations"."confirmation_status" IS 'Confirmation record state.';
-- Set comment to column: "verified_at" on table: "payment_confirmations"
COMMENT ON COLUMN "core"."payment_confirmations"."verified_at" IS 'Timestamp when provider evidence was verified.';
-- Set comment to column: "confirmed_at" on table: "payment_confirmations"
COMMENT ON COLUMN "core"."payment_confirmations"."confirmed_at" IS 'Timestamp when Central PMS recorded canonical confirmation.';
-- Set comment to column: "correlation_id" on table: "payment_confirmations"
COMMENT ON COLUMN "core"."payment_confirmations"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "payment_confirmations"
COMMENT ON COLUMN "core"."payment_confirmations"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_service_identity_id" on table: "payment_confirmations"
COMMENT ON COLUMN "core"."payment_confirmations"."created_by_service_identity_id" IS 'Service identity that created confirmation.';
-- Create "tariff_snapshots" table
CREATE TABLE "core"."tariff_snapshots" (
  "tariff_snapshot_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "parking_session_id" uuid NOT NULL,
  "superseded_by_tariff_snapshot_id" uuid NULL,
  "vendor_system_id" uuid NOT NULL,
  "vendor_tariff_ref" character varying(128) NULL,
  "tariff_version_reference" character varying(128) NULL,
  "currency_code" character(3) NOT NULL,
  "gross_amount" numeric(18,2) NOT NULL,
  "statutory_discount_amount" numeric(18,2) NOT NULL,
  "coupon_discount_amount" numeric(18,2) NOT NULL,
  "net_amount" numeric(18,2) NOT NULL,
  "statutory_discount_validation_id" uuid NULL,
  "coupon_application_id" uuid NULL,
  "snapshot_status" "core"."tariff_snapshot_status_enum" NOT NULL,
  "calculated_at" timestamptz NOT NULL,
  "expires_at" timestamptz NOT NULL,
  "consumed_at" timestamptz NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_tariff_snapshots" PRIMARY KEY ("tariff_snapshot_id")
);
-- Create index "ix_tariff_snapshots__correlation_id" to table: "tariff_snapshots"
CREATE INDEX "ix_tariff_snapshots__correlation_id" ON "core"."tariff_snapshots" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_tariff_snapshots__parking_session_id" to table: "tariff_snapshots"
CREATE INDEX "ix_tariff_snapshots__parking_session_id" ON "core"."tariff_snapshots" ("parking_session_id");
-- Create index "ix_tariff_snapshots__statutory_discount_validation_id" to table: "tariff_snapshots"
CREATE INDEX "ix_tariff_snapshots__statutory_discount_validation_id" ON "core"."tariff_snapshots" ("statutory_discount_validation_id");
-- Create index "ix_tariff_snapshots__superseded_by_tariff_snapshot_id" to table: "tariff_snapshots"
CREATE INDEX "ix_tariff_snapshots__superseded_by_tariff_snapshot_id" ON "core"."tariff_snapshots" ("superseded_by_tariff_snapshot_id");
-- Create index "ix_tariff_snapshots__vendor_system_id" to table: "tariff_snapshots"
CREATE INDEX "ix_tariff_snapshots__vendor_system_id" ON "core"."tariff_snapshots" ("vendor_system_id");
-- Create index "ux_tariff_snapshots__active_by_session" to table: "tariff_snapshots"
CREATE UNIQUE INDEX "ux_tariff_snapshots__active_by_session" ON "core"."tariff_snapshots" ("parking_session_id") WHERE (snapshot_status = 'ACTIVE'::core.tariff_snapshot_status_enum);
-- Create index "ux_tariff_snapshots__superseded_by" to table: "tariff_snapshots"
CREATE UNIQUE INDEX "ux_tariff_snapshots__superseded_by" ON "core"."tariff_snapshots" ("superseded_by_tariff_snapshot_id") WHERE (superseded_by_tariff_snapshot_id IS NOT NULL);
-- Set comment to table: "tariff_snapshots"
COMMENT ON TABLE "core"."tariff_snapshots" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "tariff_snapshot_id" on table: "tariff_snapshots"
COMMENT ON COLUMN "core"."tariff_snapshots"."tariff_snapshot_id" IS 'Canonical identifier of the tariff snapshot.';
-- Set comment to column: "parking_session_id" on table: "tariff_snapshots"
COMMENT ON COLUMN "core"."tariff_snapshots"."parking_session_id" IS 'Parking session for which this payable basis was created.';
-- Set comment to column: "superseded_by_tariff_snapshot_id" on table: "tariff_snapshots"
COMMENT ON COLUMN "core"."tariff_snapshots"."superseded_by_tariff_snapshot_id" IS 'Later snapshot that superseded this snapshot.';
-- Set comment to column: "vendor_system_id" on table: "tariff_snapshots"
COMMENT ON COLUMN "core"."tariff_snapshots"."vendor_system_id" IS 'Vendor PMS that supplied the tariff basis.';
-- Set comment to column: "vendor_tariff_ref" on table: "tariff_snapshots"
COMMENT ON COLUMN "core"."tariff_snapshots"."vendor_tariff_ref" IS 'Vendor tariff calculation reference, where available.';
-- Set comment to column: "tariff_version_reference" on table: "tariff_snapshots"
COMMENT ON COLUMN "core"."tariff_snapshots"."tariff_version_reference" IS 'Vendor or configured tariff version reference used for traceability.';
-- Set comment to column: "currency_code" on table: "tariff_snapshots"
COMMENT ON COLUMN "core"."tariff_snapshots"."currency_code" IS 'Currency code.';
-- Set comment to column: "gross_amount" on table: "tariff_snapshots"
COMMENT ON COLUMN "core"."tariff_snapshots"."gross_amount" IS 'Vendor-authoritative amount before discounts and coupons.';
-- Set comment to column: "statutory_discount_amount" on table: "tariff_snapshots"
COMMENT ON COLUMN "core"."tariff_snapshots"."statutory_discount_amount" IS 'Total statutory discount amount included in the snapshot.';
-- Set comment to column: "coupon_discount_amount" on table: "tariff_snapshots"
COMMENT ON COLUMN "core"."tariff_snapshots"."coupon_discount_amount" IS 'Total coupon amount included in the snapshot.';
-- Set comment to column: "net_amount" on table: "tariff_snapshots"
COMMENT ON COLUMN "core"."tariff_snapshots"."net_amount" IS 'Final payable amount used for payment.';
-- Set comment to column: "statutory_discount_validation_id" on table: "tariff_snapshots"
COMMENT ON COLUMN "core"."tariff_snapshots"."statutory_discount_validation_id" IS 'Approved statutory validation reflected in the snapshot, if any.';
-- Set comment to column: "coupon_application_id" on table: "tariff_snapshots"
COMMENT ON COLUMN "core"."tariff_snapshots"."coupon_application_id" IS 'Coupon application reflected in the snapshot, if any.';
-- Set comment to column: "snapshot_status" on table: "tariff_snapshots"
COMMENT ON COLUMN "core"."tariff_snapshots"."snapshot_status" IS 'Current lifecycle state of the snapshot.';
-- Set comment to column: "calculated_at" on table: "tariff_snapshots"
COMMENT ON COLUMN "core"."tariff_snapshots"."calculated_at" IS 'Timestamp when payable basis was calculated or accepted.';
-- Set comment to column: "expires_at" on table: "tariff_snapshots"
COMMENT ON COLUMN "core"."tariff_snapshots"."expires_at" IS 'Timestamp after which the snapshot may no longer create a payment attempt.';
-- Set comment to column: "consumed_at" on table: "tariff_snapshots"
COMMENT ON COLUMN "core"."tariff_snapshots"."consumed_at" IS 'Timestamp when snapshot became bound to a payment attempt.';
-- Set comment to column: "correlation_id" on table: "tariff_snapshots"
COMMENT ON COLUMN "core"."tariff_snapshots"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "tariff_snapshots"
COMMENT ON COLUMN "core"."tariff_snapshots"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_service_identity_id" on table: "tariff_snapshots"
COMMENT ON COLUMN "core"."tariff_snapshots"."created_by_service_identity_id" IS 'Service identity that created the snapshot.';
-- Set comment to column: "updated_at" on table: "tariff_snapshots"
COMMENT ON COLUMN "core"."tariff_snapshots"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_service_identity_id" on table: "tariff_snapshots"
COMMENT ON COLUMN "core"."tariff_snapshots"."updated_by_service_identity_id" IS 'Service identity that last updated the record.';
-- Set comment to column: "row_version" on table: "tariff_snapshots"
COMMENT ON COLUMN "core"."tariff_snapshots"."row_version" IS 'Optimistic concurrency version.';
-- Create enum type "coupon_application_status_enum"
CREATE TYPE "coupons"."coupon_application_status_enum" AS ENUM ('REQUESTED', 'RESERVED', 'APPLIED', 'COMMITTED', 'RELEASED', 'EXPIRED', 'REJECTED', 'CANCELLED', 'REVERSED');
-- Create enum type "coupon_denomination_type_enum"
CREATE TYPE "coupons"."coupon_denomination_type_enum" AS ENUM ('FIXED_AMOUNT', 'PERCENTAGE', 'FULL_WAIVER');
-- Create enum type "coupon_rule_evaluation_strategy_enum"
CREATE TYPE "coupons"."coupon_rule_evaluation_strategy_enum" AS ENUM ('ALL_RULES_MUST_PASS', 'ANY_RULE_MAY_PASS', 'FIRST_MATCH', 'PRIORITY_ORDERED');
-- Create enum type "coupon_rule_group_status_enum"
CREATE TYPE "coupons"."coupon_rule_group_status_enum" AS ENUM ('DRAFT', 'ACTIVE', 'SUSPENDED', 'RETIRED');
-- Create enum type "coupon_rule_operator_enum"
CREATE TYPE "coupons"."coupon_rule_operator_enum" AS ENUM ('EQUALS', 'NOT_EQUALS', 'IN', 'NOT_IN', 'GREATER_THAN', 'GREATER_THAN_OR_EQUAL', 'LESS_THAN', 'LESS_THAN_OR_EQUAL', 'BETWEEN', 'EXISTS', 'NOT_EXISTS');
-- Create enum type "coupon_rule_status_enum"
CREATE TYPE "coupons"."coupon_rule_status_enum" AS ENUM ('DRAFT', 'ACTIVE', 'SUSPENDED', 'RETIRED');
-- Create enum type "coupon_rule_type_enum"
CREATE TYPE "coupons"."coupon_rule_type_enum" AS ENUM ('SITE_GROUP_SCOPE', 'SITE_SCOPE', 'MERCHANT_SCOPE', 'VALIDITY_WINDOW', 'MINIMUM_GROSS_AMOUNT', 'MAXIMUM_DISCOUNT_AMOUNT', 'STACKING_POLICY', 'FULL_WAIVER_ALLOWED', 'WALLET_SUFFICIENCY', 'BASELINE_HOURS_ONLY', 'PAYMENT_RAIL_SCOPE', 'CUSTOM_CONTROLLED');
-- Create enum type "coupon_stacking_policy_enum"
CREATE TYPE "coupons"."coupon_stacking_policy_enum" AS ENUM ('NO_STACKING', 'STACK_WITH_STATUTORY_DISCOUNT', 'STACK_WITH_COUPON', 'STACK_WITH_BOTH', 'HIGHEST_BENEFIT_ONLY');
-- Create enum type "coupon_status_enum"
CREATE TYPE "coupons"."coupon_status_enum" AS ENUM ('DRAFT', 'ACTIVE', 'SUSPENDED', 'EXPIRED', 'RETIRED');
-- Create enum type "coupon_type_enum"
CREATE TYPE "coupons"."coupon_type_enum" AS ENUM ('STANDARD', 'MERCHANT_SUBSIDY', 'VALIDATION', 'FULL_WAIVER', 'SERVICE_RECOVERY', 'PROMOTIONAL');
-- Create "commit_coupon_application" function
CREATE FUNCTION "coupons"."commit_coupon_application" () RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'coupons.commit_coupon_application is a v1.2 routine placeholder and must be implemented before production use'; END; $$;
-- Create "release_coupon_application" function
CREATE FUNCTION "coupons"."release_coupon_application" () RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'coupons.release_coupon_application is a v1.2 routine placeholder and must be implemented before production use'; END; $$;
-- Create "reserve_coupon_application" function
CREATE FUNCTION "coupons"."reserve_coupon_application" () RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'coupons.reserve_coupon_application is a v1.2 routine placeholder and must be implemented before production use'; END; $$;
-- Create "coupon_applications" table
CREATE TABLE "coupons"."coupon_applications" (
  "coupon_application_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "coupon_id" uuid NOT NULL,
  "merchant_id" uuid NOT NULL,
  "merchant_wallet_id" uuid NULL,
  "parking_session_id" uuid NOT NULL,
  "tariff_snapshot_id" uuid NULL,
  "payment_attempt_id" uuid NULL,
  "idempotency_key" character varying(128) NOT NULL,
  "application_status" "coupons"."coupon_application_status_enum" NOT NULL,
  "currency_code" character(3) NOT NULL,
  "gross_amount_at_application" numeric(18,2) NOT NULL,
  "coupon_discount_amount" numeric(18,2) NOT NULL,
  "net_amount_after_coupon" numeric(18,2) NOT NULL,
  "reservation_ref" character varying(128) NULL,
  "reserved_at" timestamptz NULL,
  "reservation_expires_at" timestamptz NULL,
  "applied_at" timestamptz NULL,
  "committed_at" timestamptz NULL,
  "released_at" timestamptz NULL,
  "expired_at" timestamptz NULL,
  "rejected_at" timestamptz NULL,
  "cancelled_at" timestamptz NULL,
  "reversed_at" timestamptz NULL,
  "rejection_reason_code" character varying(64) NULL,
  "release_reason_code" character varying(64) NULL,
  "reversal_reason_code" character varying(64) NULL,
  "requested_by_user_id" uuid NULL,
  "requested_by_service_identity_id" uuid NULL,
  "approved_by_user_id" uuid NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_coupon_applications" PRIMARY KEY ("coupon_application_id")
);
-- Create index "ix_coupon_applications__correlation_id" to table: "coupon_applications"
CREATE INDEX "ix_coupon_applications__correlation_id" ON "coupons"."coupon_applications" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_coupon_applications__coupon_id" to table: "coupon_applications"
CREATE INDEX "ix_coupon_applications__coupon_id" ON "coupons"."coupon_applications" ("coupon_id");
-- Create index "ix_coupon_applications__merchant_id" to table: "coupon_applications"
CREATE INDEX "ix_coupon_applications__merchant_id" ON "coupons"."coupon_applications" ("merchant_id");
-- Create index "ix_coupon_applications__merchant_wallet_id" to table: "coupon_applications"
CREATE INDEX "ix_coupon_applications__merchant_wallet_id" ON "coupons"."coupon_applications" ("merchant_wallet_id");
-- Create index "ix_coupon_applications__parking_session_id" to table: "coupon_applications"
CREATE INDEX "ix_coupon_applications__parking_session_id" ON "coupons"."coupon_applications" ("parking_session_id");
-- Create index "ux_coupon_applications__active_merchant_session" to table: "coupon_applications"
CREATE UNIQUE INDEX "ux_coupon_applications__active_merchant_session" ON "coupons"."coupon_applications" ("merchant_id", "parking_session_id") WHERE (application_status = ANY (ARRAY['REQUESTED'::coupons.coupon_application_status_enum, 'RESERVED'::coupons.coupon_application_status_enum, 'APPLIED'::coupons.coupon_application_status_enum]));
-- Create index "ux_coupon_applications__reservation_ref" to table: "coupon_applications"
CREATE UNIQUE INDEX "ux_coupon_applications__reservation_ref" ON "coupons"."coupon_applications" ("reservation_ref") WHERE (reservation_ref IS NOT NULL);
-- Set comment to table: "coupon_applications"
COMMENT ON TABLE "coupons"."coupon_applications" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "coupon_application_id" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."coupon_application_id" IS 'Canonical identifier of the coupon application.';
-- Set comment to column: "coupon_id" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."coupon_id" IS 'Coupon being applied.';
-- Set comment to column: "merchant_id" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."merchant_id" IS 'Merchant sponsor of the coupon application.';
-- Set comment to column: "merchant_wallet_id" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."merchant_wallet_id" IS 'Merchant wallet or funding context backing the application.';
-- Set comment to column: "parking_session_id" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."parking_session_id" IS 'Parking session to which the coupon is applied.';
-- Set comment to column: "tariff_snapshot_id" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."tariff_snapshot_id" IS 'Tariff snapshot in which the coupon effect was materialized.';
-- Set comment to column: "payment_attempt_id" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."payment_attempt_id" IS 'Payment attempt whose finality governs commit.';
-- Set comment to column: "idempotency_key" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."idempotency_key" IS 'Idempotency key for coupon application request.';
-- Set comment to column: "application_status" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."application_status" IS 'Coupon application lifecycle state.';
-- Set comment to column: "currency_code" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."currency_code" IS 'Currency code.';
-- Set comment to column: "gross_amount_at_application" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."gross_amount_at_application" IS 'Gross amount when coupon was evaluated.';
-- Set comment to column: "coupon_discount_amount" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."coupon_discount_amount" IS 'Coupon amount applied or reserved.';
-- Set comment to column: "net_amount_after_coupon" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."net_amount_after_coupon" IS 'Amount after coupon effect, before or after other allowed effects depending on flow.';
-- Set comment to column: "reservation_ref" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."reservation_ref" IS 'Internal or wallet reservation reference.';
-- Set comment to column: "reserved_at" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."reserved_at" IS 'Timestamp when coupon value was reserved.';
-- Set comment to column: "reservation_expires_at" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."reservation_expires_at" IS 'Reservation expiry timestamp.';
-- Set comment to column: "applied_at" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."applied_at" IS 'Timestamp when coupon effect was applied to payable basis.';
-- Set comment to column: "committed_at" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."committed_at" IS 'Timestamp when coupon usage was committed after confirmed payment finality.';
-- Set comment to column: "released_at" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."released_at" IS 'Timestamp when reservation was released.';
-- Set comment to column: "expired_at" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."expired_at" IS 'Timestamp when application or reservation expired.';
-- Set comment to column: "rejected_at" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."rejected_at" IS 'Timestamp when application was rejected.';
-- Set comment to column: "cancelled_at" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."cancelled_at" IS 'Timestamp when application was cancelled.';
-- Set comment to column: "reversed_at" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."reversed_at" IS 'Timestamp when committed application was reversed, if supported.';
-- Set comment to column: "rejection_reason_code" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."rejection_reason_code" IS 'Controlled rejection reason.';
-- Set comment to column: "release_reason_code" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."release_reason_code" IS 'Controlled release reason.';
-- Set comment to column: "reversal_reason_code" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."reversal_reason_code" IS 'Controlled reversal reason.';
-- Set comment to column: "requested_by_user_id" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."requested_by_user_id" IS 'User who requested the coupon application.';
-- Set comment to column: "requested_by_service_identity_id" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."requested_by_service_identity_id" IS 'Service identity that requested the application.';
-- Set comment to column: "approved_by_user_id" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."approved_by_user_id" IS 'Approver for elevated coupon or full-waiver use.';
-- Set comment to column: "correlation_id" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."created_by_user_id" IS 'User who created the record.';
-- Set comment to column: "created_by_service_identity_id" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."created_by_service_identity_id" IS 'Service identity that created the record.';
-- Set comment to column: "updated_at" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."updated_by_user_id" IS 'User who last updated the record.';
-- Set comment to column: "updated_by_service_identity_id" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."updated_by_service_identity_id" IS 'Service identity that last updated the record.';
-- Set comment to column: "row_version" on table: "coupon_applications"
COMMENT ON COLUMN "coupons"."coupon_applications"."row_version" IS 'Optimistic concurrency version.';
-- Create "coupon_rule_groups" table
CREATE TABLE "coupons"."coupon_rule_groups" (
  "coupon_rule_group_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "coupon_id" uuid NOT NULL,
  "rule_group_code" character varying(64) NOT NULL,
  "rule_group_name" character varying(128) NOT NULL,
  "rule_group_description" text NULL,
  "evaluation_strategy" "coupons"."coupon_rule_evaluation_strategy_enum" NOT NULL,
  "evaluation_priority" integer NOT NULL,
  "is_required" boolean NOT NULL DEFAULT false,
  "rule_group_status" "coupons"."coupon_rule_group_status_enum" NOT NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_coupon_rule_groups" PRIMARY KEY ("coupon_rule_group_id"),
  CONSTRAINT "uq_coupon_rule_groups__coupon_rule_group_code" UNIQUE ("coupon_id", "rule_group_code")
);
-- Create index "ix_coupon_rule_groups__coupon_id" to table: "coupon_rule_groups"
CREATE INDEX "ix_coupon_rule_groups__coupon_id" ON "coupons"."coupon_rule_groups" ("coupon_id");
-- Create index "ix_coupon_rule_groups__rule_group_status" to table: "coupon_rule_groups"
CREATE INDEX "ix_coupon_rule_groups__rule_group_status" ON "coupons"."coupon_rule_groups" ("rule_group_status");
-- Set comment to table: "coupon_rule_groups"
COMMENT ON TABLE "coupons"."coupon_rule_groups" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "coupon_rule_group_id" on table: "coupon_rule_groups"
COMMENT ON COLUMN "coupons"."coupon_rule_groups"."coupon_rule_group_id" IS 'Canonical identifier of the coupon rule group.';
-- Set comment to column: "coupon_id" on table: "coupon_rule_groups"
COMMENT ON COLUMN "coupons"."coupon_rule_groups"."coupon_id" IS 'Coupon to which the rule group belongs.';
-- Set comment to column: "rule_group_code" on table: "coupon_rule_groups"
COMMENT ON COLUMN "coupons"."coupon_rule_groups"."rule_group_code" IS 'Stable code for the rule group.';
-- Set comment to column: "rule_group_name" on table: "coupon_rule_groups"
COMMENT ON COLUMN "coupons"."coupon_rule_groups"."rule_group_name" IS 'Human-readable name.';
-- Set comment to column: "rule_group_description" on table: "coupon_rule_groups"
COMMENT ON COLUMN "coupons"."coupon_rule_groups"."rule_group_description" IS 'Description of the rule group.';
-- Set comment to column: "evaluation_strategy" on table: "coupon_rule_groups"
COMMENT ON COLUMN "coupons"."coupon_rule_groups"."evaluation_strategy" IS 'Rule group evaluation strategy.';
-- Set comment to column: "evaluation_priority" on table: "coupon_rule_groups"
COMMENT ON COLUMN "coupons"."coupon_rule_groups"."evaluation_priority" IS 'Evaluation priority when multiple groups exist.';
-- Set comment to column: "is_required" on table: "coupon_rule_groups"
COMMENT ON COLUMN "coupons"."coupon_rule_groups"."is_required" IS 'Indicates whether the group must pass for eligibility.';
-- Set comment to column: "rule_group_status" on table: "coupon_rule_groups"
COMMENT ON COLUMN "coupons"."coupon_rule_groups"."rule_group_status" IS 'Rule group lifecycle status.';
-- Set comment to column: "effective_from" on table: "coupon_rule_groups"
COMMENT ON COLUMN "coupons"."coupon_rule_groups"."effective_from" IS 'Start of rule group effectiveness.';
-- Set comment to column: "effective_to" on table: "coupon_rule_groups"
COMMENT ON COLUMN "coupons"."coupon_rule_groups"."effective_to" IS 'End of rule group effectiveness.';
-- Set comment to column: "created_at" on table: "coupon_rule_groups"
COMMENT ON COLUMN "coupons"."coupon_rule_groups"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "coupon_rule_groups"
COMMENT ON COLUMN "coupons"."coupon_rule_groups"."created_by_user_id" IS 'User who created the rule group.';
-- Set comment to column: "created_by_service_identity_id" on table: "coupon_rule_groups"
COMMENT ON COLUMN "coupons"."coupon_rule_groups"."created_by_service_identity_id" IS 'Service identity that created the rule group.';
-- Set comment to column: "updated_at" on table: "coupon_rule_groups"
COMMENT ON COLUMN "coupons"."coupon_rule_groups"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "coupon_rule_groups"
COMMENT ON COLUMN "coupons"."coupon_rule_groups"."updated_by_user_id" IS 'User who last updated the rule group.';
-- Set comment to column: "updated_by_service_identity_id" on table: "coupon_rule_groups"
COMMENT ON COLUMN "coupons"."coupon_rule_groups"."updated_by_service_identity_id" IS 'Service identity that last updated the rule group.';
-- Set comment to column: "row_version" on table: "coupon_rule_groups"
COMMENT ON COLUMN "coupons"."coupon_rule_groups"."row_version" IS 'Optimistic concurrency version.';
-- Create "coupon_rules" table
CREATE TABLE "coupons"."coupon_rules" (
  "coupon_rule_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "coupon_rule_group_id" uuid NOT NULL,
  "rule_code" character varying(64) NOT NULL,
  "rule_name" character varying(128) NOT NULL,
  "rule_type" "coupons"."coupon_rule_type_enum" NOT NULL,
  "rule_operator" "coupons"."coupon_rule_operator_enum" NOT NULL,
  "rule_value_text" character varying(256) NULL,
  "rule_value_numeric" numeric(18,2) NULL,
  "rule_value_boolean" boolean NULL,
  "site_group_id" uuid NULL,
  "site_id" uuid NULL,
  "merchant_id" uuid NULL,
  "rule_status" "coupons"."coupon_rule_status_enum" NOT NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_coupon_rules" PRIMARY KEY ("coupon_rule_id"),
  CONSTRAINT "uq_coupon_rules__group_rule_code" UNIQUE ("coupon_rule_group_id", "rule_code")
);
-- Create index "ix_coupon_rules__coupon_rule_group_id" to table: "coupon_rules"
CREATE INDEX "ix_coupon_rules__coupon_rule_group_id" ON "coupons"."coupon_rules" ("coupon_rule_group_id");
-- Create index "ix_coupon_rules__site_group_id" to table: "coupon_rules"
CREATE INDEX "ix_coupon_rules__site_group_id" ON "coupons"."coupon_rules" ("site_group_id");
-- Create index "ix_coupon_rules__site_id" to table: "coupon_rules"
CREATE INDEX "ix_coupon_rules__site_id" ON "coupons"."coupon_rules" ("site_id");
-- Set comment to table: "coupon_rules"
COMMENT ON TABLE "coupons"."coupon_rules" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "coupon_rule_id" on table: "coupon_rules"
COMMENT ON COLUMN "coupons"."coupon_rules"."coupon_rule_id" IS 'Canonical identifier of the coupon rule.';
-- Set comment to column: "coupon_rule_group_id" on table: "coupon_rules"
COMMENT ON COLUMN "coupons"."coupon_rules"."coupon_rule_group_id" IS 'Parent rule group.';
-- Set comment to column: "rule_code" on table: "coupon_rules"
COMMENT ON COLUMN "coupons"."coupon_rules"."rule_code" IS 'Stable rule code.';
-- Set comment to column: "rule_name" on table: "coupon_rules"
COMMENT ON COLUMN "coupons"."coupon_rules"."rule_name" IS 'Human-readable rule name.';
-- Set comment to column: "rule_type" on table: "coupon_rules"
COMMENT ON COLUMN "coupons"."coupon_rules"."rule_type" IS 'Type of rule.';
-- Set comment to column: "rule_operator" on table: "coupon_rules"
COMMENT ON COLUMN "coupons"."coupon_rules"."rule_operator" IS 'Operator used for evaluation.';
-- Set comment to column: "rule_value_text" on table: "coupon_rules"
COMMENT ON COLUMN "coupons"."coupon_rules"."rule_value_text" IS 'Text value for rule evaluation.';
-- Set comment to column: "rule_value_numeric" on table: "coupon_rules"
COMMENT ON COLUMN "coupons"."coupon_rules"."rule_value_numeric" IS 'Numeric value for rule evaluation.';
-- Set comment to column: "rule_value_boolean" on table: "coupon_rules"
COMMENT ON COLUMN "coupons"."coupon_rules"."rule_value_boolean" IS 'Boolean value for rule evaluation.';
-- Set comment to column: "site_group_id" on table: "coupon_rules"
COMMENT ON COLUMN "coupons"."coupon_rules"."site_group_id" IS 'Site group scope where the rule applies.';
-- Set comment to column: "site_id" on table: "coupon_rules"
COMMENT ON COLUMN "coupons"."coupon_rules"."site_id" IS 'Site scope where the rule applies.';
-- Set comment to column: "merchant_id" on table: "coupon_rules"
COMMENT ON COLUMN "coupons"."coupon_rules"."merchant_id" IS 'Merchant scope where the rule applies.';
-- Set comment to column: "rule_status" on table: "coupon_rules"
COMMENT ON COLUMN "coupons"."coupon_rules"."rule_status" IS 'Rule lifecycle status.';
-- Set comment to column: "effective_from" on table: "coupon_rules"
COMMENT ON COLUMN "coupons"."coupon_rules"."effective_from" IS 'Start of rule effectiveness.';
-- Set comment to column: "effective_to" on table: "coupon_rules"
COMMENT ON COLUMN "coupons"."coupon_rules"."effective_to" IS 'End of rule effectiveness.';
-- Set comment to column: "created_at" on table: "coupon_rules"
COMMENT ON COLUMN "coupons"."coupon_rules"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "coupon_rules"
COMMENT ON COLUMN "coupons"."coupon_rules"."created_by_user_id" IS 'User who created the rule.';
-- Set comment to column: "created_by_service_identity_id" on table: "coupon_rules"
COMMENT ON COLUMN "coupons"."coupon_rules"."created_by_service_identity_id" IS 'Service identity that created the rule.';
-- Set comment to column: "updated_at" on table: "coupon_rules"
COMMENT ON COLUMN "coupons"."coupon_rules"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "coupon_rules"
COMMENT ON COLUMN "coupons"."coupon_rules"."updated_by_user_id" IS 'User who last updated the rule.';
-- Set comment to column: "updated_by_service_identity_id" on table: "coupon_rules"
COMMENT ON COLUMN "coupons"."coupon_rules"."updated_by_service_identity_id" IS 'Service identity that last updated the rule.';
-- Set comment to column: "row_version" on table: "coupon_rules"
COMMENT ON COLUMN "coupons"."coupon_rules"."row_version" IS 'Optimistic concurrency version.';
-- Create "coupons" table
CREATE TABLE "coupons"."coupons" (
  "coupon_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "merchant_id" uuid NOT NULL,
  "coupon_code" character varying(64) NOT NULL,
  "coupon_name" character varying(128) NOT NULL,
  "coupon_description" text NULL,
  "coupon_type" "coupons"."coupon_type_enum" NOT NULL,
  "denomination_type" "coupons"."coupon_denomination_type_enum" NOT NULL,
  "denomination_value" numeric(18,2) NOT NULL,
  "currency_code" character(3) NULL,
  "maximum_discount_amount" numeric(18,2) NULL,
  "minimum_gross_amount" numeric(18,2) NULL,
  "stacking_policy" "coupons"."coupon_stacking_policy_enum" NOT NULL,
  "allows_full_waiver" boolean NOT NULL DEFAULT false,
  "requires_elevated_approval" boolean NOT NULL DEFAULT false,
  "coupon_status" "coupons"."coupon_status_enum" NOT NULL,
  "valid_from" timestamptz NOT NULL,
  "valid_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_coupons" PRIMARY KEY ("coupon_id"),
  CONSTRAINT "uq_coupons__merchant_coupon_code" UNIQUE ("merchant_id", "coupon_code")
);
-- Create index "ix_coupons__coupon_status" to table: "coupons"
CREATE INDEX "ix_coupons__coupon_status" ON "coupons"."coupons" ("coupon_status");
-- Create index "ix_coupons__merchant_id" to table: "coupons"
CREATE INDEX "ix_coupons__merchant_id" ON "coupons"."coupons" ("merchant_id");
-- Set comment to table: "coupons"
COMMENT ON TABLE "coupons"."coupons" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "coupon_id" on table: "coupons"
COMMENT ON COLUMN "coupons"."coupons"."coupon_id" IS 'Canonical identifier of the coupon.';
-- Set comment to column: "merchant_id" on table: "coupons"
COMMENT ON COLUMN "coupons"."coupons"."merchant_id" IS 'Merchant sponsor of the coupon.';
-- Set comment to column: "coupon_code" on table: "coupons"
COMMENT ON COLUMN "coupons"."coupons"."coupon_code" IS 'Stable coupon code.';
-- Set comment to column: "coupon_name" on table: "coupons"
COMMENT ON COLUMN "coupons"."coupons"."coupon_name" IS 'Human-readable coupon name.';
-- Set comment to column: "coupon_description" on table: "coupons"
COMMENT ON COLUMN "coupons"."coupons"."coupon_description" IS 'Description of the coupon program.';
-- Set comment to column: "coupon_type" on table: "coupons"
COMMENT ON COLUMN "coupons"."coupons"."coupon_type" IS 'Coupon type or commercial category.';
-- Set comment to column: "denomination_type" on table: "coupons"
COMMENT ON COLUMN "coupons"."coupons"."denomination_type" IS 'Discount denomination type.';
-- Set comment to column: "denomination_value" on table: "coupons"
COMMENT ON COLUMN "coupons"."coupons"."denomination_value" IS 'Fixed amount, percentage, or controlled value depending on denomination type.';
-- Set comment to column: "currency_code" on table: "coupons"
COMMENT ON COLUMN "coupons"."coupons"."currency_code" IS 'Currency code for fixed-amount coupons.';
-- Set comment to column: "maximum_discount_amount" on table: "coupons"
COMMENT ON COLUMN "coupons"."coupons"."maximum_discount_amount" IS 'Maximum discount amount where capped.';
-- Set comment to column: "minimum_gross_amount" on table: "coupons"
COMMENT ON COLUMN "coupons"."coupons"."minimum_gross_amount" IS 'Minimum gross amount required for coupon use.';
-- Set comment to column: "stacking_policy" on table: "coupons"
COMMENT ON COLUMN "coupons"."coupons"."stacking_policy" IS 'Stacking behavior with other coupons or statutory discounts.';
-- Set comment to column: "allows_full_waiver" on table: "coupons"
COMMENT ON COLUMN "coupons"."coupons"."allows_full_waiver" IS 'Indicates whether the coupon may waive the full payable amount.';
-- Set comment to column: "requires_elevated_approval" on table: "coupons"
COMMENT ON COLUMN "coupons"."coupons"."requires_elevated_approval" IS 'Indicates whether coupon use requires elevated approval.';
-- Set comment to column: "coupon_status" on table: "coupons"
COMMENT ON COLUMN "coupons"."coupons"."coupon_status" IS 'Coupon lifecycle status.';
-- Set comment to column: "valid_from" on table: "coupons"
COMMENT ON COLUMN "coupons"."coupons"."valid_from" IS 'Start of coupon validity.';
-- Set comment to column: "valid_to" on table: "coupons"
COMMENT ON COLUMN "coupons"."coupons"."valid_to" IS 'End of coupon validity.';
-- Set comment to column: "created_at" on table: "coupons"
COMMENT ON COLUMN "coupons"."coupons"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "coupons"
COMMENT ON COLUMN "coupons"."coupons"."created_by_user_id" IS 'User who created the coupon.';
-- Set comment to column: "created_by_service_identity_id" on table: "coupons"
COMMENT ON COLUMN "coupons"."coupons"."created_by_service_identity_id" IS 'Service identity that created the coupon.';
-- Set comment to column: "updated_at" on table: "coupons"
COMMENT ON COLUMN "coupons"."coupons"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "coupons"
COMMENT ON COLUMN "coupons"."coupons"."updated_by_user_id" IS 'User who last updated the coupon.';
-- Set comment to column: "updated_by_service_identity_id" on table: "coupons"
COMMENT ON COLUMN "coupons"."coupons"."updated_by_service_identity_id" IS 'Service identity that last updated the coupon.';
-- Set comment to column: "row_version" on table: "coupons"
COMMENT ON COLUMN "coupons"."coupons"."row_version" IS 'Optimistic concurrency version.';
-- Create enum type "discount_evidence_type_enum"
CREATE TYPE "discounts"."discount_evidence_type_enum" AS ENUM ('SENIOR_CITIZEN_ID', 'PWD_ID', 'AUTHORIZATION_LETTER', 'SUPPORTING_DOCUMENT', 'VALIDATION_SCREENSHOT', 'HASH_ONLY_REFERENCE', 'OTHER');
-- Create enum type "discount_policy_level_enum"
CREATE TYPE "discounts"."discount_policy_level_enum" AS ENUM ('NATIONAL_LAW', 'LOCAL_ORDINANCE', 'SITE_POLICY', 'OPERATIONAL_POLICY');
-- Create enum type "discount_policy_status_enum"
CREATE TYPE "discounts"."discount_policy_status_enum" AS ENUM ('DRAFT', 'ACTIVE', 'SUSPENDED', 'SUPERSEDED', 'RETIRED');
-- Create enum type "discount_policy_type_enum"
CREATE TYPE "discounts"."discount_policy_type_enum" AS ENUM ('LEGAL_REFERENCE', 'LOCAL_ORDINANCE', 'SITE_POLICY', 'OPERATIONAL_POLICY', 'IMPLEMENTATION_POLICY');
-- Create enum type "evidence_access_classification_enum"
CREATE TYPE "discounts"."evidence_access_classification_enum" AS ENUM ('INTERNAL', 'RESTRICTED', 'HIGHLY_RESTRICTED');
-- Create enum type "evidence_capture_status_enum"
CREATE TYPE "discounts"."evidence_capture_status_enum" AS ENUM ('CAPTURED', 'REFERENCED', 'REDACTED', 'PURGED', 'HASH_ONLY', 'REJECTED');
-- Create enum type "evidence_redaction_status_enum"
CREATE TYPE "discounts"."evidence_redaction_status_enum" AS ENUM ('NOT_REDACTED', 'PARTIALLY_REDACTED', 'FULLY_REDACTED', 'HASH_ONLY');
-- Create enum type "evidence_storage_type_enum"
CREATE TYPE "discounts"."evidence_storage_type_enum" AS ENUM ('OBJECT_STORAGE', 'EVIDENCE_VAULT', 'HASH_ONLY', 'EXTERNAL_REFERENCE', 'REDACTED_REFERENCE');
-- Create enum type "policy_resolution_basis_enum"
CREATE TYPE "discounts"."policy_resolution_basis_enum" AS ENUM ('LOCAL_ORDINANCE_APPLIED', 'NATIONAL_LAW_FALLBACK', 'SITE_POLICY_OPERATIONAL_ONLY', 'MANUAL_POLICY_SELECTION', 'SYSTEM_DEFAULT');
-- Create enum type "statutory_discount_validations_channel_enum"
CREATE TYPE "discounts"."statutory_discount_validations_channel_enum" AS ENUM ('WEB_PAY', 'OPERATOR_ASSISTED', 'SYSTEM_VALIDATED', 'SUPPORT_REVIEW', 'RECONCILIATION_REVIEW');
-- Create enum type "statutory_discount_validations_status_enum"
CREATE TYPE "discounts"."statutory_discount_validations_status_enum" AS ENUM ('REQUESTED', 'PENDING_OPERATOR_REVIEW', 'APPROVED', 'REJECTED', 'FAILED', 'EXPIRED', 'CANCELLED');
-- Create enum type "statutory_entitlement_type_enum"
CREATE TYPE "discounts"."statutory_entitlement_type_enum" AS ENUM ('SENIOR_CITIZEN', 'PWD', 'OTHER_STATUTORY');
-- Create "record_statutory_discount_validation" function
CREATE FUNCTION "discounts"."record_statutory_discount_validation" () RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'discounts.record_statutory_discount_validation is a v1.2 routine placeholder and must be implemented before production use'; END; $$;
-- Create "discount_evidence_references" table
CREATE TABLE "discounts"."discount_evidence_references" (
  "discount_evidence_reference_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "statutory_discount_validation_id" uuid NOT NULL,
  "evidence_type" "discounts"."discount_evidence_type_enum" NOT NULL,
  "evidence_storage_type" "discounts"."evidence_storage_type_enum" NOT NULL,
  "evidence_storage_ref" character varying(256) NULL,
  "evidence_hash" character(64) NULL,
  "evidence_capture_status" "discounts"."evidence_capture_status_enum" NOT NULL,
  "access_classification" "discounts"."evidence_access_classification_enum" NOT NULL,
  "redaction_status" "discounts"."evidence_redaction_status_enum" NOT NULL,
  "retention_policy_code" character varying(64) NOT NULL,
  "retention_expires_at" timestamptz NULL,
  "captured_at" timestamptz NOT NULL,
  "captured_by_user_id" uuid NULL,
  "captured_by_service_identity_id" uuid NULL,
  "purged_at" timestamptz NULL,
  "purged_by_user_id" uuid NULL,
  "purged_by_service_identity_id" uuid NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_discount_evidence_references" PRIMARY KEY ("discount_evidence_reference_id")
);
-- Create index "ix_discount_evidence_references__correlation_id" to table: "discount_evidence_references"
CREATE INDEX "ix_discount_evidence_references__correlation_id" ON "discounts"."discount_evidence_references" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_discount_evidence_references__evidence_capture_status" to table: "discount_evidence_references"
CREATE INDEX "ix_discount_evidence_references__evidence_capture_status" ON "discounts"."discount_evidence_references" ("evidence_capture_status");
-- Create index "ix_discount_evidence_references__redaction_status" to table: "discount_evidence_references"
CREATE INDEX "ix_discount_evidence_references__redaction_status" ON "discounts"."discount_evidence_references" ("redaction_status");
-- Create index "ix_discount_evidence_references__retention_expires_at" to table: "discount_evidence_references"
CREATE INDEX "ix_discount_evidence_references__retention_expires_at" ON "discounts"."discount_evidence_references" ("retention_expires_at");
-- Create index "ix_discount_evidence_references__statutory_discount_validati" to table: "discount_evidence_references"
CREATE INDEX "ix_discount_evidence_references__statutory_discount_validati" ON "discounts"."discount_evidence_references" ("statutory_discount_validation_id");
-- Create index "ux_discount_evidence_references__evidence_hash" to table: "discount_evidence_references"
CREATE UNIQUE INDEX "ux_discount_evidence_references__evidence_hash" ON "discounts"."discount_evidence_references" ("evidence_hash") WHERE (evidence_hash IS NOT NULL);
-- Set comment to table: "discount_evidence_references"
COMMENT ON TABLE "discounts"."discount_evidence_references" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "discount_evidence_reference_id" on table: "discount_evidence_references"
COMMENT ON COLUMN "discounts"."discount_evidence_references"."discount_evidence_reference_id" IS 'Canonical identifier of the evidence reference.';
-- Set comment to column: "statutory_discount_validation_id" on table: "discount_evidence_references"
COMMENT ON COLUMN "discounts"."discount_evidence_references"."statutory_discount_validation_id" IS 'Validation record supported by this evidence reference.';
-- Set comment to column: "evidence_type" on table: "discount_evidence_references"
COMMENT ON COLUMN "discounts"."discount_evidence_references"."evidence_type" IS 'Type of evidence referenced.';
-- Set comment to column: "evidence_storage_type" on table: "discount_evidence_references"
COMMENT ON COLUMN "discounts"."discount_evidence_references"."evidence_storage_type" IS 'Storage mechanism or reference type.';
-- Set comment to column: "evidence_storage_ref" on table: "discount_evidence_references"
COMMENT ON COLUMN "discounts"."discount_evidence_references"."evidence_storage_ref" IS 'Object key, evidence vault reference, URI reference, or controlled storage reference.';
-- Set comment to column: "evidence_hash" on table: "discount_evidence_references"
COMMENT ON COLUMN "discounts"."discount_evidence_references"."evidence_hash" IS 'Hash of evidence content where retained.';
-- Set comment to column: "evidence_capture_status" on table: "discount_evidence_references"
COMMENT ON COLUMN "discounts"."discount_evidence_references"."evidence_capture_status" IS 'Evidence reference lifecycle state.';
-- Set comment to column: "access_classification" on table: "discount_evidence_references"
COMMENT ON COLUMN "discounts"."discount_evidence_references"."access_classification" IS 'Access classification.';
-- Set comment to column: "redaction_status" on table: "discount_evidence_references"
COMMENT ON COLUMN "discounts"."discount_evidence_references"."redaction_status" IS 'Redaction or minimization state.';
-- Set comment to column: "retention_policy_code" on table: "discount_evidence_references"
COMMENT ON COLUMN "discounts"."discount_evidence_references"."retention_policy_code" IS 'Retention policy applied to the evidence.';
-- Set comment to column: "retention_expires_at" on table: "discount_evidence_references"
COMMENT ON COLUMN "discounts"."discount_evidence_references"."retention_expires_at" IS 'Date/time when evidence becomes eligible for purge or redaction.';
-- Set comment to column: "captured_at" on table: "discount_evidence_references"
COMMENT ON COLUMN "discounts"."discount_evidence_references"."captured_at" IS 'Timestamp when evidence reference was captured.';
-- Set comment to column: "captured_by_user_id" on table: "discount_evidence_references"
COMMENT ON COLUMN "discounts"."discount_evidence_references"."captured_by_user_id" IS 'User who captured the evidence.';
-- Set comment to column: "captured_by_service_identity_id" on table: "discount_evidence_references"
COMMENT ON COLUMN "discounts"."discount_evidence_references"."captured_by_service_identity_id" IS 'Service identity that captured the evidence.';
-- Set comment to column: "purged_at" on table: "discount_evidence_references"
COMMENT ON COLUMN "discounts"."discount_evidence_references"."purged_at" IS 'Timestamp when evidence payload was purged, if applicable.';
-- Set comment to column: "purged_by_user_id" on table: "discount_evidence_references"
COMMENT ON COLUMN "discounts"."discount_evidence_references"."purged_by_user_id" IS 'User who purged the evidence.';
-- Set comment to column: "purged_by_service_identity_id" on table: "discount_evidence_references"
COMMENT ON COLUMN "discounts"."discount_evidence_references"."purged_by_service_identity_id" IS 'Service identity that purged the evidence.';
-- Set comment to column: "correlation_id" on table: "discount_evidence_references"
COMMENT ON COLUMN "discounts"."discount_evidence_references"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "discount_evidence_references"
COMMENT ON COLUMN "discounts"."discount_evidence_references"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "discount_evidence_references"
COMMENT ON COLUMN "discounts"."discount_evidence_references"."created_by_user_id" IS 'User who created the reference.';
-- Set comment to column: "created_by_service_identity_id" on table: "discount_evidence_references"
COMMENT ON COLUMN "discounts"."discount_evidence_references"."created_by_service_identity_id" IS 'Service identity that created the reference.';
-- Set comment to column: "updated_at" on table: "discount_evidence_references"
COMMENT ON COLUMN "discounts"."discount_evidence_references"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "discount_evidence_references"
COMMENT ON COLUMN "discounts"."discount_evidence_references"."updated_by_user_id" IS 'User who last updated the reference.';
-- Set comment to column: "updated_by_service_identity_id" on table: "discount_evidence_references"
COMMENT ON COLUMN "discounts"."discount_evidence_references"."updated_by_service_identity_id" IS 'Service identity that last updated the reference.';
-- Set comment to column: "row_version" on table: "discount_evidence_references"
COMMENT ON COLUMN "discounts"."discount_evidence_references"."row_version" IS 'Optimistic concurrency version.';
-- Create "discount_policy_references" table
CREATE TABLE "discounts"."discount_policy_references" (
  "discount_policy_reference_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "policy_code" character varying(64) NOT NULL,
  "policy_name" character varying(256) NOT NULL,
  "policy_description" text NULL,
  "policy_type" "discounts"."discount_policy_type_enum" NOT NULL,
  "policy_level" "discounts"."discount_policy_level_enum" NOT NULL,
  "entitlement_type" "discounts"."statutory_entitlement_type_enum" NOT NULL,
  "national_law_reference" character varying(128) NULL,
  "local_ordinance_reference" character varying(128) NULL,
  "lgu_code" character varying(32) NULL,
  "jurisdiction_name" character varying(128) NULL,
  "site_group_id" uuid NULL,
  "site_id" uuid NULL,
  "parent_policy_reference_id" uuid NULL,
  "fallback_policy_reference_id" uuid NULL,
  "precedence_rank" integer NOT NULL,
  "policy_version" character varying(32) NOT NULL,
  "requires_operator_validation" boolean NOT NULL DEFAULT false,
  "requires_evidence_capture" boolean NOT NULL DEFAULT false,
  "evidence_retention_policy_code" character varying(64) NULL,
  "policy_status" "discounts"."discount_policy_status_enum" NOT NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_discount_policy_references" PRIMARY KEY ("discount_policy_reference_id"),
  CONSTRAINT "uq_discount_policy_references__policy_code_version" UNIQUE ("policy_code", "policy_version")
);
-- Create index "ix_discount_policy_references__parent_policy_reference_id" to table: "discount_policy_references"
CREATE INDEX "ix_discount_policy_references__parent_policy_reference_id" ON "discounts"."discount_policy_references" ("parent_policy_reference_id");
-- Create index "ix_discount_policy_references__site_group_id" to table: "discount_policy_references"
CREATE INDEX "ix_discount_policy_references__site_group_id" ON "discounts"."discount_policy_references" ("site_group_id");
-- Create index "ix_discount_policy_references__site_id" to table: "discount_policy_references"
CREATE INDEX "ix_discount_policy_references__site_id" ON "discounts"."discount_policy_references" ("site_id");
-- Create index "ux_discount_policy_references__active_local_policy" to table: "discount_policy_references"
CREATE UNIQUE INDEX "ux_discount_policy_references__active_local_policy" ON "discounts"."discount_policy_references" ("entitlement_type", "lgu_code", "site_group_id", "site_id", "policy_level", "policy_version") WHERE ((policy_status = 'ACTIVE'::discounts.discount_policy_status_enum) AND (lgu_code IS NOT NULL));
-- Set comment to table: "discount_policy_references"
COMMENT ON TABLE "discounts"."discount_policy_references" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "discount_policy_reference_id" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."discount_policy_reference_id" IS 'Canonical identifier of the discount policy reference.';
-- Set comment to column: "policy_code" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."policy_code" IS 'Stable internal policy code.';
-- Set comment to column: "policy_name" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."policy_name" IS 'Human-readable policy name.';
-- Set comment to column: "policy_description" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."policy_description" IS 'Description of the policy reference.';
-- Set comment to column: "policy_type" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."policy_type" IS 'Type of policy reference.';
-- Set comment to column: "policy_level" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."policy_level" IS 'Legal or operational level of the policy.';
-- Set comment to column: "entitlement_type" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."entitlement_type" IS 'Statutory entitlement category governed by the policy.';
-- Set comment to column: "national_law_reference" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."national_law_reference" IS 'National law reference where applicable.';
-- Set comment to column: "local_ordinance_reference" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."local_ordinance_reference" IS 'Local ordinance number or code where applicable.';
-- Set comment to column: "lgu_code" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."lgu_code" IS 'LGU or jurisdiction code where applicable.';
-- Set comment to column: "jurisdiction_name" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."jurisdiction_name" IS 'Human-readable jurisdiction name.';
-- Set comment to column: "site_group_id" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."site_group_id" IS 'Site group scope where policy applies.';
-- Set comment to column: "site_id" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."site_id" IS 'Site scope where policy applies.';
-- Set comment to column: "parent_policy_reference_id" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."parent_policy_reference_id" IS 'Parent policy reference.';
-- Set comment to column: "fallback_policy_reference_id" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."fallback_policy_reference_id" IS 'Fallback policy reference, usually national law.';
-- Set comment to column: "precedence_rank" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."precedence_rank" IS 'Policy precedence within applicable scope.';
-- Set comment to column: "policy_version" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."policy_version" IS 'Policy version or controlled implementation version.';
-- Set comment to column: "requires_operator_validation" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."requires_operator_validation" IS 'Indicates whether assisted operator validation is required.';
-- Set comment to column: "requires_evidence_capture" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."requires_evidence_capture" IS 'Indicates whether evidence reference is required.';
-- Set comment to column: "evidence_retention_policy_code" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."evidence_retention_policy_code" IS 'Retention policy code for evidence.';
-- Set comment to column: "policy_status" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."policy_status" IS 'Policy lifecycle status.';
-- Set comment to column: "effective_from" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."effective_from" IS 'Start of policy effectiveness.';
-- Set comment to column: "effective_to" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."effective_to" IS 'End of policy effectiveness.';
-- Set comment to column: "created_at" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."created_by_user_id" IS 'User who created the policy reference.';
-- Set comment to column: "created_by_service_identity_id" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."created_by_service_identity_id" IS 'Service identity that created the policy reference.';
-- Set comment to column: "updated_at" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."updated_by_user_id" IS 'User who last updated the policy reference.';
-- Set comment to column: "updated_by_service_identity_id" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."updated_by_service_identity_id" IS 'Service identity that last updated the policy reference.';
-- Set comment to column: "row_version" on table: "discount_policy_references"
COMMENT ON COLUMN "discounts"."discount_policy_references"."row_version" IS 'Optimistic concurrency version.';
-- Create "statutory_discount_validations" table
CREATE TABLE "discounts"."statutory_discount_validations" (
  "statutory_discount_validation_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "parking_session_id" uuid NOT NULL,
  "tariff_snapshot_id" uuid NULL,
  "entitlement_type" "discounts"."statutory_entitlement_type_enum" NOT NULL,
  "evaluated_policy_reference_id" uuid NULL,
  "applied_policy_reference_id" uuid NULL,
  "fallback_policy_reference_id" uuid NULL,
  "policy_resolution_basis" "discounts"."policy_resolution_basis_enum" NOT NULL,
  "local_ordinance_applied" boolean NOT NULL DEFAULT false,
  "national_law_fallback_applied" boolean NOT NULL DEFAULT false,
  "validation_channel" "discounts"."statutory_discount_validations_channel_enum" NOT NULL,
  "validation_status" "discounts"."statutory_discount_validations_status_enum" NOT NULL,
  "currency_code" character(3) NULL,
  "gross_amount_at_validation" numeric(18,2) NULL,
  "statutory_discount_amount" numeric(18,2) NULL,
  "net_amount_after_discount" numeric(18,2) NULL,
  "evidence_required" boolean NOT NULL DEFAULT false,
  "evidence_captured" boolean NOT NULL DEFAULT false,
  "decision_reason_code" character varying(64) NULL,
  "failure_reason_code" character varying(64) NULL,
  "requested_at" timestamptz NOT NULL,
  "validated_at" timestamptz NULL,
  "expires_at" timestamptz NULL,
  "validated_by_user_id" uuid NULL,
  "validated_by_service_identity_id" uuid NULL,
  "requested_by_user_id" uuid NULL,
  "requested_by_service_identity_id" uuid NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_statutory_discount_validations" PRIMARY KEY ("statutory_discount_validation_id")
);
-- Create index "ix_statutory_discount_validations__applied_policy_reference_" to table: "statutory_discount_validations"
CREATE INDEX "ix_statutory_discount_validations__applied_policy_reference_" ON "discounts"."statutory_discount_validations" ("applied_policy_reference_id");
-- Create index "ix_statutory_discount_validations__correlation_id" to table: "statutory_discount_validations"
CREATE INDEX "ix_statutory_discount_validations__correlation_id" ON "discounts"."statutory_discount_validations" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_statutory_discount_validations__fallback_policy_reference" to table: "statutory_discount_validations"
CREATE INDEX "ix_statutory_discount_validations__fallback_policy_reference" ON "discounts"."statutory_discount_validations" ("fallback_policy_reference_id");
-- Create index "ix_statutory_discount_validations__parking_session_id" to table: "statutory_discount_validations"
CREATE INDEX "ix_statutory_discount_validations__parking_session_id" ON "discounts"."statutory_discount_validations" ("parking_session_id");
-- Create index "ix_statutory_discount_validations__tariff_snapshot_id" to table: "statutory_discount_validations"
CREATE INDEX "ix_statutory_discount_validations__tariff_snapshot_id" ON "discounts"."statutory_discount_validations" ("tariff_snapshot_id");
-- Create index "ux_statutory_discount_validations__active_session_entitlement" to table: "statutory_discount_validations"
CREATE UNIQUE INDEX "ux_statutory_discount_validations__active_session_entitlement" ON "discounts"."statutory_discount_validations" ("parking_session_id", "entitlement_type") WHERE (validation_status = ANY (ARRAY['REQUESTED'::discounts.statutory_discount_validations_status_enum, 'PENDING_OPERATOR_REVIEW'::discounts.statutory_discount_validations_status_enum, 'APPROVED'::discounts.statutory_discount_validations_status_enum]));
-- Set comment to table: "statutory_discount_validations"
COMMENT ON TABLE "discounts"."statutory_discount_validations" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "statutory_discount_validation_id" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."statutory_discount_validation_id" IS 'Canonical identifier of the statutory discount validation.';
-- Set comment to column: "parking_session_id" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."parking_session_id" IS 'Parking session for which validation was requested.';
-- Set comment to column: "tariff_snapshot_id" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."tariff_snapshot_id" IS 'Tariff snapshot where approved discount effect was materialized.';
-- Set comment to column: "entitlement_type" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."entitlement_type" IS 'Entitlement category requested.';
-- Set comment to column: "evaluated_policy_reference_id" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."evaluated_policy_reference_id" IS 'Policy initially evaluated.';
-- Set comment to column: "applied_policy_reference_id" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."applied_policy_reference_id" IS 'Final policy applied to the decision.';
-- Set comment to column: "fallback_policy_reference_id" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."fallback_policy_reference_id" IS 'Fallback policy used, usually national law.';
-- Set comment to column: "policy_resolution_basis" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."policy_resolution_basis" IS 'How policy was selected.';
-- Set comment to column: "local_ordinance_applied" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."local_ordinance_applied" IS 'Indicates whether a local ordinance governed the validation.';
-- Set comment to column: "national_law_fallback_applied" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."national_law_fallback_applied" IS 'Indicates whether national law fallback was used.';
-- Set comment to column: "validation_channel" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."validation_channel" IS 'Channel used for validation.';
-- Set comment to column: "validation_status" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."validation_status" IS 'Validation lifecycle state.';
-- Set comment to column: "currency_code" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."currency_code" IS 'Currency code for discount amount fields.';
-- Set comment to column: "gross_amount_at_validation" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."gross_amount_at_validation" IS 'Gross amount at time of validation.';
-- Set comment to column: "statutory_discount_amount" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."statutory_discount_amount" IS 'Approved statutory discount amount.';
-- Set comment to column: "net_amount_after_discount" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."net_amount_after_discount" IS 'Amount after approved statutory discount.';
-- Set comment to column: "evidence_required" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."evidence_required" IS 'Indicates whether evidence was required.';
-- Set comment to column: "evidence_captured" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."evidence_captured" IS 'Indicates whether evidence reference exists or was captured.';
-- Set comment to column: "decision_reason_code" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."decision_reason_code" IS 'Controlled decision reason.';
-- Set comment to column: "failure_reason_code" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."failure_reason_code" IS 'Controlled failure reason.';
-- Set comment to column: "requested_at" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."requested_at" IS 'Timestamp when validation was requested.';
-- Set comment to column: "validated_at" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."validated_at" IS 'Timestamp when validation decision was completed.';
-- Set comment to column: "expires_at" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."expires_at" IS 'Expiry timestamp for validation usability.';
-- Set comment to column: "validated_by_user_id" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."validated_by_user_id" IS 'Human operator who performed validation.';
-- Set comment to column: "validated_by_service_identity_id" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."validated_by_service_identity_id" IS 'Service identity that performed validation.';
-- Set comment to column: "requested_by_user_id" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."requested_by_user_id" IS 'User who requested the validation.';
-- Set comment to column: "requested_by_service_identity_id" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."requested_by_service_identity_id" IS 'Service identity that requested the validation.';
-- Set comment to column: "correlation_id" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."created_by_user_id" IS 'User who created the record.';
-- Set comment to column: "created_by_service_identity_id" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."created_by_service_identity_id" IS 'Service identity that created the record.';
-- Set comment to column: "updated_at" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."updated_by_user_id" IS 'User who last updated the record.';
-- Set comment to column: "updated_by_service_identity_id" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."updated_by_service_identity_id" IS 'Service identity that last updated the record.';
-- Set comment to column: "row_version" on table: "statutory_discount_validations"
COMMENT ON COLUMN "discounts"."statutory_discount_validations"."row_version" IS 'Optimistic concurrency version.';
-- Create enum type "consumer_checkpoint_status_enum"
CREATE TYPE "events"."consumer_checkpoint_status_enum" AS ENUM ('ACTIVE', 'LOCKED', 'FAILED', 'PAUSED', 'REPLAYING', 'RESET', 'RETIRED');
-- Create enum type "dead_letter_status_enum"
CREATE TYPE "events"."dead_letter_status_enum" AS ENUM ('OPEN', 'UNDER_REVIEW', 'REPLAY_REQUESTED', 'REPLAYED', 'RESOLVED', 'REJECTED', 'CLOSED', 'CANCELLED');
-- Create enum type "dead_letter_type_enum"
CREATE TYPE "events"."dead_letter_type_enum" AS ENUM ('PUBLICATION_FAILURE', 'BROKER_REJECTION', 'PAYLOAD_VALIDATION_FAILURE', 'ROUTING_FAILURE', 'CONSUMER_FAILURE', 'CONSUMER_REJECTION', 'RETRY_EXHAUSTED', 'UNKNOWN');
-- Create enum type "domain_event_status_enum"
CREATE TYPE "events"."domain_event_status_enum" AS ENUM ('RECORDED', 'SUPERSEDED', 'CANCELLED', 'IGNORED');
-- Create enum type "event_broker_type_enum"
CREATE TYPE "events"."event_broker_type_enum" AS ENUM ('RABBITMQ', 'KAFKA', 'AZURE_SERVICE_BUS', 'AWS_SNS_SQS', 'WEBHOOK', 'IN_PROCESS', 'OTHER');
-- Create enum type "event_publication_status_enum"
CREATE TYPE "events"."event_publication_status_enum" AS ENUM ('STARTED', 'PUBLISHED', 'FAILED', 'TIMEOUT', 'REJECTED', 'CANCELLED');
-- Create enum type "outbox_publication_status_enum"
CREATE TYPE "events"."outbox_publication_status_enum" AS ENUM ('PENDING', 'LOCKED', 'PUBLISHED', 'FAILED', 'RETRY_PENDING', 'DEAD_LETTERED', 'CANCELLED');
-- Create "enqueue_outbox_event" function
CREATE FUNCTION "events"."enqueue_outbox_event" () RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'events.enqueue_outbox_event is a v1.2 routine placeholder and must be implemented before production use'; END; $$;
-- Create "consumer_checkpoints" table
CREATE TABLE "events"."consumer_checkpoints" (
  "consumer_checkpoint_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "consumer_name" character varying(128) NOT NULL,
  "consumer_group" character varying(128) NULL,
  "subscription_name" character varying(128) NULL,
  "event_type" character varying(128) NULL,
  "aggregate_type" character varying(96) NULL,
  "last_outbox_event_id" uuid NULL,
  "last_domain_event_id" uuid NULL,
  "last_broker_offset" character varying(128) NULL,
  "checkpoint_status" "events"."consumer_checkpoint_status_enum" NOT NULL,
  "processed_count" bigint NOT NULL DEFAULT 0,
  "failure_count" bigint NOT NULL DEFAULT 0,
  "last_processed_at" timestamptz NULL,
  "last_failed_at" timestamptz NULL,
  "failure_reason_code" character varying(64) NULL,
  "locked_at" timestamptz NULL,
  "locked_by_service_identity_id" uuid NULL,
  "updated_by_service_identity_id" uuid NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "correlation_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_consumer_checkpoints" PRIMARY KEY ("consumer_checkpoint_id")
);
-- Create index "ix_consumer_checkpoints__checkpoint_status" to table: "consumer_checkpoints"
CREATE INDEX "ix_consumer_checkpoints__checkpoint_status" ON "events"."consumer_checkpoints" ("checkpoint_status");
-- Create index "ix_consumer_checkpoints__correlation_id" to table: "consumer_checkpoints"
CREATE INDEX "ix_consumer_checkpoints__correlation_id" ON "events"."consumer_checkpoints" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_consumer_checkpoints__last_domain_event_id" to table: "consumer_checkpoints"
CREATE INDEX "ix_consumer_checkpoints__last_domain_event_id" ON "events"."consumer_checkpoints" ("last_domain_event_id");
-- Create index "ix_consumer_checkpoints__last_outbox_event_id" to table: "consumer_checkpoints"
CREATE INDEX "ix_consumer_checkpoints__last_outbox_event_id" ON "events"."consumer_checkpoints" ("last_outbox_event_id");
-- Create index "ix_consumer_checkpoints__last_processed_at" to table: "consumer_checkpoints"
CREATE INDEX "ix_consumer_checkpoints__last_processed_at" ON "events"."consumer_checkpoints" ("last_processed_at");
-- Create index "ux_consumer_checkpoints__consumer_scope" to table: "consumer_checkpoints"
CREATE UNIQUE INDEX "ux_consumer_checkpoints__consumer_scope" ON "events"."consumer_checkpoints" ("consumer_name", (COALESCE(consumer_group, ''::character varying)), (COALESCE(subscription_name, ''::character varying)), (COALESCE(event_type, ''::character varying)), (COALESCE(aggregate_type, ''::character varying)));
-- Set comment to table: "consumer_checkpoints"
COMMENT ON TABLE "events"."consumer_checkpoints" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "consumer_checkpoint_id" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."consumer_checkpoint_id" IS 'Canonical identifier of the consumer checkpoint.';
-- Set comment to column: "consumer_name" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."consumer_name" IS 'Stable consumer name.';
-- Set comment to column: "consumer_group" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."consumer_group" IS 'Consumer group name, where applicable.';
-- Set comment to column: "subscription_name" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."subscription_name" IS 'Queue, subscription, topic, or routing subscription name.';
-- Set comment to column: "event_type" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."event_type" IS 'Event type checkpoint applies to, if scoped.';
-- Set comment to column: "aggregate_type" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."aggregate_type" IS 'Aggregate type checkpoint applies to, if scoped.';
-- Set comment to column: "last_outbox_event_id" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."last_outbox_event_id" IS 'Last processed outbox event.';
-- Set comment to column: "last_domain_event_id" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."last_domain_event_id" IS 'Last processed domain event, where applicable.';
-- Set comment to column: "last_broker_offset" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."last_broker_offset" IS 'Broker offset, delivery tag, sequence, or cursor.';
-- Set comment to column: "checkpoint_status" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."checkpoint_status" IS 'Checkpoint lifecycle or processing status.';
-- Set comment to column: "processed_count" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."processed_count" IS 'Count of processed events tracked by this checkpoint.';
-- Set comment to column: "failure_count" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."failure_count" IS 'Count of processing failures tracked by this checkpoint.';
-- Set comment to column: "last_processed_at" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."last_processed_at" IS 'Timestamp when last event was processed.';
-- Set comment to column: "last_failed_at" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."last_failed_at" IS 'Timestamp of last processing failure.';
-- Set comment to column: "failure_reason_code" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."failure_reason_code" IS 'Controlled failure reason.';
-- Set comment to column: "locked_at" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."locked_at" IS 'Timestamp when checkpoint was locked for processing.';
-- Set comment to column: "locked_by_service_identity_id" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."locked_by_service_identity_id" IS 'Consumer service identity holding the lock.';
-- Set comment to column: "updated_by_service_identity_id" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."updated_by_service_identity_id" IS 'Consumer service identity that last updated the checkpoint.';
-- Set comment to column: "created_at" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "updated_at" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "correlation_id" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "row_version" on table: "consumer_checkpoints"
COMMENT ON COLUMN "events"."consumer_checkpoints"."row_version" IS 'Optimistic concurrency version for checkpoint safety.';
-- Create "dead_letter_records" table
CREATE TABLE "events"."dead_letter_records" (
  "dead_letter_record_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "outbox_event_id" uuid NULL,
  "event_publication_id" uuid NULL,
  "consumer_name" character varying(128) NULL,
  "dead_letter_type" "events"."dead_letter_type_enum" NOT NULL,
  "dead_letter_status" "events"."dead_letter_status_enum" NOT NULL,
  "failure_reason_code" character varying(64) NOT NULL,
  "failure_detail_ref" character varying(256) NULL,
  "payload_hash" character(64) NULL,
  "dead_lettered_at" timestamptz NOT NULL DEFAULT now(),
  "resolved_at" timestamptz NULL,
  "resolved_by_user_id" uuid NULL,
  "resolved_by_service_identity_id" uuid NULL,
  "resolution_reason_code" character varying(64) NULL,
  "replay_requested_at" timestamptz NULL,
  "replay_requested_by_user_id" uuid NULL,
  "replay_requested_by_service_identity_id" uuid NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_dead_letter_records" PRIMARY KEY ("dead_letter_record_id")
);
-- Create index "ix_dead_letter_records__correlation_id" to table: "dead_letter_records"
CREATE INDEX "ix_dead_letter_records__correlation_id" ON "events"."dead_letter_records" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_dead_letter_records__dead_letter_status" to table: "dead_letter_records"
CREATE INDEX "ix_dead_letter_records__dead_letter_status" ON "events"."dead_letter_records" ("dead_letter_status");
-- Create index "ix_dead_letter_records__dead_lettered_at" to table: "dead_letter_records"
CREATE INDEX "ix_dead_letter_records__dead_lettered_at" ON "events"."dead_letter_records" ("dead_lettered_at");
-- Create index "ix_dead_letter_records__event_publication_id" to table: "dead_letter_records"
CREATE INDEX "ix_dead_letter_records__event_publication_id" ON "events"."dead_letter_records" ("event_publication_id");
-- Create index "ix_dead_letter_records__outbox_event_id" to table: "dead_letter_records"
CREATE INDEX "ix_dead_letter_records__outbox_event_id" ON "events"."dead_letter_records" ("outbox_event_id");
-- Create index "ix_dead_letter_records__replay_requested_at" to table: "dead_letter_records"
CREATE INDEX "ix_dead_letter_records__replay_requested_at" ON "events"."dead_letter_records" ("replay_requested_at");
-- Create index "ix_dead_letter_records__resolved_at" to table: "dead_letter_records"
CREATE INDEX "ix_dead_letter_records__resolved_at" ON "events"."dead_letter_records" ("resolved_at");
-- Set comment to table: "dead_letter_records"
COMMENT ON TABLE "events"."dead_letter_records" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "dead_letter_record_id" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."dead_letter_record_id" IS 'Canonical identifier of the dead-letter record.';
-- Set comment to column: "outbox_event_id" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."outbox_event_id" IS 'Outbox event that dead-lettered.';
-- Set comment to column: "event_publication_id" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."event_publication_id" IS 'Publication attempt that caused dead-lettering, where applicable.';
-- Set comment to column: "consumer_name" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."consumer_name" IS 'Consumer that dead-lettered the event, where consumer-side dead-lettering is recorded.';
-- Set comment to column: "dead_letter_type" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."dead_letter_type" IS 'Dead-letter category.';
-- Set comment to column: "dead_letter_status" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."dead_letter_status" IS 'Dead-letter lifecycle status.';
-- Set comment to column: "failure_reason_code" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."failure_reason_code" IS 'Controlled failure reason.';
-- Set comment to column: "failure_detail_ref" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."failure_detail_ref" IS 'Reference to detailed failure evidence.';
-- Set comment to column: "payload_hash" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."payload_hash" IS 'Payload hash associated with dead-lettered event.';
-- Set comment to column: "dead_lettered_at" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."dead_lettered_at" IS 'Timestamp when event was dead-lettered.';
-- Set comment to column: "resolved_at" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."resolved_at" IS 'Timestamp when dead-letter was resolved.';
-- Set comment to column: "resolved_by_user_id" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."resolved_by_user_id" IS 'User who resolved dead-letter record.';
-- Set comment to column: "resolved_by_service_identity_id" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."resolved_by_service_identity_id" IS 'Service identity that resolved dead-letter record.';
-- Set comment to column: "resolution_reason_code" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."resolution_reason_code" IS 'Controlled resolution reason.';
-- Set comment to column: "replay_requested_at" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."replay_requested_at" IS 'Timestamp when replay was requested.';
-- Set comment to column: "replay_requested_by_user_id" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."replay_requested_by_user_id" IS 'User who requested replay.';
-- Set comment to column: "replay_requested_by_service_identity_id" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."replay_requested_by_service_identity_id" IS 'Service identity that requested replay.';
-- Set comment to column: "correlation_id" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_service_identity_id" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."created_by_service_identity_id" IS 'Service identity that created the dead-letter record.';
-- Set comment to column: "updated_at" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."updated_by_user_id" IS 'User who last updated the dead-letter record.';
-- Set comment to column: "updated_by_service_identity_id" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."updated_by_service_identity_id" IS 'Service identity that last updated the dead-letter record.';
-- Set comment to column: "row_version" on table: "dead_letter_records"
COMMENT ON COLUMN "events"."dead_letter_records"."row_version" IS 'Optimistic concurrency version.';
-- Create "domain_events" table
CREATE TABLE "events"."domain_events" (
  "domain_event_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "source_schema" character varying(64) NOT NULL,
  "source_table" character varying(96) NULL,
  "event_type" character varying(128) NOT NULL,
  "event_version" integer NOT NULL DEFAULT 1,
  "aggregate_type" character varying(96) NOT NULL,
  "aggregate_id" uuid NOT NULL,
  "related_entity_type" character varying(96) NULL,
  "related_entity_id" uuid NULL,
  "event_status" "events"."domain_event_status_enum" NOT NULL,
  "payload_ref" character varying(256) NULL,
  "payload_hash" character(64) NULL,
  "metadata_ref" character varying(256) NULL,
  "occurred_at" timestamptz NOT NULL,
  "recorded_at" timestamptz NOT NULL DEFAULT now(),
  "actor_user_id" uuid NULL,
  "actor_service_identity_id" uuid NULL,
  "correlation_id" uuid NULL,
  "causation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NULL,
  CONSTRAINT "pk_domain_events" PRIMARY KEY ("domain_event_id")
);
-- Create index "ix_domain_events__actor_service_identity_id" to table: "domain_events"
CREATE INDEX "ix_domain_events__actor_service_identity_id" ON "events"."domain_events" ("actor_service_identity_id");
-- Create index "ix_domain_events__actor_user_id" to table: "domain_events"
CREATE INDEX "ix_domain_events__actor_user_id" ON "events"."domain_events" ("actor_user_id");
-- Create index "ix_domain_events__causation_id" to table: "domain_events"
CREATE INDEX "ix_domain_events__causation_id" ON "events"."domain_events" ("causation_id") WHERE (causation_id IS NOT NULL);
-- Create index "ix_domain_events__correlation_id" to table: "domain_events"
CREATE INDEX "ix_domain_events__correlation_id" ON "events"."domain_events" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_domain_events__event_status" to table: "domain_events"
CREATE INDEX "ix_domain_events__event_status" ON "events"."domain_events" ("event_status");
-- Set comment to table: "domain_events"
COMMENT ON TABLE "events"."domain_events" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "domain_event_id" on table: "domain_events"
COMMENT ON COLUMN "events"."domain_events"."domain_event_id" IS 'Canonical identifier of the domain event.';
-- Set comment to column: "source_schema" on table: "domain_events"
COMMENT ON COLUMN "events"."domain_events"."source_schema" IS 'Source schema that raised the event.';
-- Set comment to column: "source_table" on table: "domain_events"
COMMENT ON COLUMN "events"."domain_events"."source_table" IS 'Source table associated with the event.';
-- Set comment to column: "event_type" on table: "domain_events"
COMMENT ON COLUMN "events"."domain_events"."event_type" IS 'Stable domain event type.';
-- Set comment to column: "event_version" on table: "domain_events"
COMMENT ON COLUMN "events"."domain_events"."event_version" IS 'Event schema version.';
-- Set comment to column: "aggregate_type" on table: "domain_events"
COMMENT ON COLUMN "events"."domain_events"."aggregate_type" IS 'Aggregate or domain object type.';
-- Set comment to column: "aggregate_id" on table: "domain_events"
COMMENT ON COLUMN "events"."domain_events"."aggregate_id" IS 'Aggregate or domain record identifier.';
-- Set comment to column: "related_entity_type" on table: "domain_events"
COMMENT ON COLUMN "events"."domain_events"."related_entity_type" IS 'Related entity type, where applicable.';
-- Set comment to column: "related_entity_id" on table: "domain_events"
COMMENT ON COLUMN "events"."domain_events"."related_entity_id" IS 'Related entity identifier, where applicable.';
-- Set comment to column: "event_status" on table: "domain_events"
COMMENT ON COLUMN "events"."domain_events"."event_status" IS 'Domain event lifecycle status.';
-- Set comment to column: "payload_ref" on table: "domain_events"
COMMENT ON COLUMN "events"."domain_events"."payload_ref" IS 'Reference to event payload if stored externally.';
-- Set comment to column: "payload_hash" on table: "domain_events"
COMMENT ON COLUMN "events"."domain_events"."payload_hash" IS 'Hash of event payload.';
-- Set comment to column: "metadata_ref" on table: "domain_events"
COMMENT ON COLUMN "events"."domain_events"."metadata_ref" IS 'Reference to event metadata if stored externally.';
-- Set comment to column: "occurred_at" on table: "domain_events"
COMMENT ON COLUMN "events"."domain_events"."occurred_at" IS 'Timestamp when source-domain fact occurred.';
-- Set comment to column: "recorded_at" on table: "domain_events"
COMMENT ON COLUMN "events"."domain_events"."recorded_at" IS 'Timestamp when event was recorded.';
-- Set comment to column: "actor_user_id" on table: "domain_events"
COMMENT ON COLUMN "events"."domain_events"."actor_user_id" IS 'Human actor associated with the event, where applicable.';
-- Set comment to column: "actor_service_identity_id" on table: "domain_events"
COMMENT ON COLUMN "events"."domain_events"."actor_service_identity_id" IS 'Service, worker, adapter, or device actor associated with the event.';
-- Set comment to column: "correlation_id" on table: "domain_events"
COMMENT ON COLUMN "events"."domain_events"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "causation_id" on table: "domain_events"
COMMENT ON COLUMN "events"."domain_events"."causation_id" IS 'Causation identifier where this event was caused by another action or event.';
-- Set comment to column: "created_at" on table: "domain_events"
COMMENT ON COLUMN "events"."domain_events"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_service_identity_id" on table: "domain_events"
COMMENT ON COLUMN "events"."domain_events"."created_by_service_identity_id" IS 'Service identity that wrote the event record.';
-- Create "event_publications" table
CREATE TABLE "events"."event_publications" (
  "event_publication_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "outbox_event_id" uuid NOT NULL,
  "publication_attempt_number" integer NOT NULL,
  "publisher_service_identity_id" uuid NOT NULL,
  "broker_type" "events"."event_broker_type_enum" NOT NULL,
  "exchange_name" character varying(128) NULL,
  "routing_key" character varying(160) NULL,
  "publication_status" "events"."event_publication_status_enum" NOT NULL,
  "broker_message_id" character varying(128) NULL,
  "broker_acknowledged" boolean NULL,
  "failure_reason_code" character varying(64) NULL,
  "failure_detail_ref" character varying(256) NULL,
  "started_at" timestamptz NOT NULL DEFAULT now(),
  "completed_at" timestamptz NULL,
  "duration_ms" integer NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT "pk_event_publications" PRIMARY KEY ("event_publication_id")
);
-- Create index "ix_event_publications__completed_at" to table: "event_publications"
CREATE INDEX "ix_event_publications__completed_at" ON "events"."event_publications" ("completed_at");
-- Create index "ix_event_publications__correlation_id" to table: "event_publications"
CREATE INDEX "ix_event_publications__correlation_id" ON "events"."event_publications" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_event_publications__outbox_event_id" to table: "event_publications"
CREATE INDEX "ix_event_publications__outbox_event_id" ON "events"."event_publications" ("outbox_event_id");
-- Create index "ix_event_publications__publication_status" to table: "event_publications"
CREATE INDEX "ix_event_publications__publication_status" ON "events"."event_publications" ("publication_status");
-- Create index "ix_event_publications__started_at" to table: "event_publications"
CREATE INDEX "ix_event_publications__started_at" ON "events"."event_publications" ("started_at");
-- Set comment to table: "event_publications"
COMMENT ON TABLE "events"."event_publications" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "event_publication_id" on table: "event_publications"
COMMENT ON COLUMN "events"."event_publications"."event_publication_id" IS 'Canonical identifier of the publication attempt.';
-- Set comment to column: "outbox_event_id" on table: "event_publications"
COMMENT ON COLUMN "events"."event_publications"."outbox_event_id" IS 'Outbox event being published.';
-- Set comment to column: "publication_attempt_number" on table: "event_publications"
COMMENT ON COLUMN "events"."event_publications"."publication_attempt_number" IS 'Sequential attempt number for the outbox event.';
-- Set comment to column: "publisher_service_identity_id" on table: "event_publications"
COMMENT ON COLUMN "events"."event_publications"."publisher_service_identity_id" IS 'Dispatcher or publisher service identity.';
-- Set comment to column: "broker_type" on table: "event_publications"
COMMENT ON COLUMN "events"."event_publications"."broker_type" IS 'Broker or transport type.';
-- Set comment to column: "exchange_name" on table: "event_publications"
COMMENT ON COLUMN "events"."event_publications"."exchange_name" IS 'Exchange name used.';
-- Set comment to column: "routing_key" on table: "event_publications"
COMMENT ON COLUMN "events"."event_publications"."routing_key" IS 'Routing key or topic used.';
-- Set comment to column: "publication_status" on table: "event_publications"
COMMENT ON COLUMN "events"."event_publications"."publication_status" IS 'Publication attempt result.';
-- Set comment to column: "broker_message_id" on table: "event_publications"
COMMENT ON COLUMN "events"."event_publications"."broker_message_id" IS 'Broker-assigned message ID, where available.';
-- Set comment to column: "broker_acknowledged" on table: "event_publications"
COMMENT ON COLUMN "events"."event_publications"."broker_acknowledged" IS 'Whether broker acknowledged the publication.';
-- Set comment to column: "failure_reason_code" on table: "event_publications"
COMMENT ON COLUMN "events"."event_publications"."failure_reason_code" IS 'Controlled publication failure reason.';
-- Set comment to column: "failure_detail_ref" on table: "event_publications"
COMMENT ON COLUMN "events"."event_publications"."failure_detail_ref" IS 'Reference to detailed failure evidence, if retained.';
-- Set comment to column: "started_at" on table: "event_publications"
COMMENT ON COLUMN "events"."event_publications"."started_at" IS 'Publication attempt start timestamp.';
-- Set comment to column: "completed_at" on table: "event_publications"
COMMENT ON COLUMN "events"."event_publications"."completed_at" IS 'Publication attempt completion timestamp.';
-- Set comment to column: "duration_ms" on table: "event_publications"
COMMENT ON COLUMN "events"."event_publications"."duration_ms" IS 'Publication duration in milliseconds.';
-- Set comment to column: "correlation_id" on table: "event_publications"
COMMENT ON COLUMN "events"."event_publications"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "event_publications"
COMMENT ON COLUMN "events"."event_publications"."created_at" IS 'Record creation timestamp.';
-- Create "outbox_events" table
CREATE TABLE "events"."outbox_events" (
  "outbox_event_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "domain_event_id" uuid NULL,
  "source_schema" character varying(64) NOT NULL,
  "source_table" character varying(96) NULL,
  "event_type" character varying(128) NOT NULL,
  "event_version" integer NOT NULL DEFAULT 1,
  "aggregate_type" character varying(96) NOT NULL,
  "aggregate_id" uuid NOT NULL,
  "routing_key" character varying(160) NOT NULL,
  "exchange_name" character varying(128) NULL,
  "payload_ref" character varying(256) NULL,
  "payload_hash" character(64) NULL,
  "payload_content_type" character varying(64) NOT NULL,
  "publication_status" "events"."outbox_publication_status_enum" NOT NULL,
  "available_at" timestamptz NOT NULL DEFAULT now(),
  "locked_at" timestamptz NULL,
  "locked_by_service_identity_id" uuid NULL,
  "published_at" timestamptz NULL,
  "next_retry_at" timestamptz NULL,
  "retry_count" integer NOT NULL DEFAULT 0,
  "max_retry_count" integer NOT NULL DEFAULT 10,
  "failure_reason_code" character varying(64) NULL,
  "correlation_id" uuid NULL,
  "causation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_outbox_events" PRIMARY KEY ("outbox_event_id")
);
-- Create index "ix_outbox_events__available_at" to table: "outbox_events"
CREATE INDEX "ix_outbox_events__available_at" ON "events"."outbox_events" ("available_at");
-- Create index "ix_outbox_events__causation_id" to table: "outbox_events"
CREATE INDEX "ix_outbox_events__causation_id" ON "events"."outbox_events" ("causation_id") WHERE (causation_id IS NOT NULL);
-- Create index "ix_outbox_events__correlation_id" to table: "outbox_events"
CREATE INDEX "ix_outbox_events__correlation_id" ON "events"."outbox_events" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_outbox_events__domain_event_id" to table: "outbox_events"
CREATE INDEX "ix_outbox_events__domain_event_id" ON "events"."outbox_events" ("domain_event_id");
-- Create index "ix_outbox_events__next_retry_at" to table: "outbox_events"
CREATE INDEX "ix_outbox_events__next_retry_at" ON "events"."outbox_events" ("next_retry_at");
-- Create index "ix_outbox_events__publication_status" to table: "outbox_events"
CREATE INDEX "ix_outbox_events__publication_status" ON "events"."outbox_events" ("publication_status");
-- Create index "ix_outbox_events__published_at" to table: "outbox_events"
CREATE INDEX "ix_outbox_events__published_at" ON "events"."outbox_events" ("published_at");
-- Create index "ux_outbox_events__domain_event" to table: "outbox_events"
CREATE UNIQUE INDEX "ux_outbox_events__domain_event" ON "events"."outbox_events" ("domain_event_id") WHERE (domain_event_id IS NOT NULL);
-- Set comment to table: "outbox_events"
COMMENT ON TABLE "events"."outbox_events" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "outbox_event_id" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."outbox_event_id" IS 'Canonical identifier of the outbox event.';
-- Set comment to column: "domain_event_id" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."domain_event_id" IS 'Related domain event, where domain_events is used.';
-- Set comment to column: "source_schema" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."source_schema" IS 'Source schema that produced the outbox event.';
-- Set comment to column: "source_table" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."source_table" IS 'Source table associated with the event.';
-- Set comment to column: "event_type" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."event_type" IS 'Event type to publish.';
-- Set comment to column: "event_version" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."event_version" IS 'Published event schema version.';
-- Set comment to column: "aggregate_type" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."aggregate_type" IS 'Aggregate or source domain object type.';
-- Set comment to column: "aggregate_id" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."aggregate_id" IS 'Aggregate or source domain object identifier.';
-- Set comment to column: "routing_key" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."routing_key" IS 'Broker routing key or topic name.';
-- Set comment to column: "exchange_name" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."exchange_name" IS 'Broker exchange name, where applicable.';
-- Set comment to column: "payload_ref" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."payload_ref" IS 'Reference to event payload if stored externally.';
-- Set comment to column: "payload_hash" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."payload_hash" IS 'Hash of event payload.';
-- Set comment to column: "payload_content_type" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."payload_content_type" IS 'Payload content type.';
-- Set comment to column: "publication_status" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."publication_status" IS 'Outbox publication lifecycle status.';
-- Set comment to column: "available_at" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."available_at" IS 'Timestamp when event becomes eligible for dispatch.';
-- Set comment to column: "locked_at" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."locked_at" IS 'Timestamp when dispatcher locked the event for processing.';
-- Set comment to column: "locked_by_service_identity_id" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."locked_by_service_identity_id" IS 'Dispatcher service identity that locked the event.';
-- Set comment to column: "published_at" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."published_at" IS 'Timestamp when publication succeeded.';
-- Set comment to column: "next_retry_at" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."next_retry_at" IS 'Next retry timestamp after failed publication.';
-- Set comment to column: "retry_count" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."retry_count" IS 'Number of publication attempts.';
-- Set comment to column: "max_retry_count" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."max_retry_count" IS 'Maximum allowed retry attempts before dead-letter handling.';
-- Set comment to column: "failure_reason_code" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."failure_reason_code" IS 'Controlled failure reason.';
-- Set comment to column: "correlation_id" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "causation_id" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."causation_id" IS 'Causation identifier.';
-- Set comment to column: "created_at" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_service_identity_id" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."created_by_service_identity_id" IS 'Service identity that created the outbox event.';
-- Set comment to column: "updated_at" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_service_identity_id" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."updated_by_service_identity_id" IS 'Service identity that last updated the outbox event.';
-- Set comment to column: "row_version" on table: "outbox_events"
COMMENT ON COLUMN "events"."outbox_events"."row_version" IS 'Optimistic concurrency version for dispatcher safety.';
-- Create enum type "gate_authorization_consumption_status_enum"
CREATE TYPE "gates"."gate_authorization_consumption_status_enum" AS ENUM ('REQUESTED', 'VALIDATED', 'CONSUMED', 'DENIED', 'EXPIRED', 'INVALID', 'REPLAYED', 'MISMATCHED', 'FAILED');
-- Create enum type "gate_command_result_status_enum"
CREATE TYPE "gates"."gate_command_result_status_enum" AS ENUM ('NOT_REQUESTED', 'REQUESTED', 'ACKNOWLEDGED', 'OPENED', 'FAILED', 'TIMEOUT', 'UNKNOWN');
-- Create enum type "gate_device_status_enum"
CREATE TYPE "gates"."gate_device_status_enum" AS ENUM ('DRAFT', 'ACTIVE', 'MAINTENANCE', 'OFFLINE', 'SUSPENDED', 'RETIRED');
-- Create enum type "gate_device_type_enum"
CREATE TYPE "gates"."gate_device_type_enum" AS ENUM ('BARRIER_CONTROLLER', 'LANE_CONTROLLER', 'EXIT_TERMINAL', 'LPR_DEVICE', 'GATEWAY', 'INTEGRATION_ENDPOINT', 'OTHER');
-- Create enum type "gate_event_status_enum"
CREATE TYPE "gates"."gate_event_status_enum" AS ENUM ('RECORDED', 'SUCCESS', 'FAILED', 'ERROR', 'ABNORMAL', 'IGNORED', 'DUPLICATE');
-- Create enum type "gate_event_type_enum"
CREATE TYPE "gates"."gate_event_type_enum" AS ENUM ('AUTHORIZATION_PRESENTED', 'AUTHORIZATION_VALIDATED', 'AUTHORIZATION_DENIED', 'AUTHORIZATION_CONSUMED', 'GATE_OPEN_COMMAND_REQUESTED', 'GATE_OPEN_ACKNOWLEDGED', 'GATE_OPEN_FAILED', 'BARRIER_RAISED', 'BARRIER_LOWERED', 'VEHICLE_DETECTED', 'VEHICLE_EXITED', 'DEVICE_ONLINE', 'DEVICE_OFFLINE', 'DEVICE_ERROR', 'MANUAL_INTERVENTION', 'TAMPER_ALERT', 'ABNORMAL_EVENT');
-- Create enum type "gate_heartbeat_status_enum"
CREATE TYPE "gates"."gate_heartbeat_status_enum" AS ENUM ('ONLINE', 'DEGRADED', 'OFFLINE', 'ERROR', 'UNKNOWN');
-- Create "consume_exit_authorization" function
CREATE FUNCTION "gates"."consume_exit_authorization" () RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'gates.consume_exit_authorization is a v1.2 routine placeholder and must be implemented before production use'; END; $$;
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
);
-- Create index "ix_gate_authorization_consumptions__command_result_status" to table: "gate_authorization_consumptions"
CREATE INDEX "ix_gate_authorization_consumptions__command_result_status" ON "gates"."gate_authorization_consumptions" ("command_result_status");
-- Create index "ix_gate_authorization_consumptions__consume_status" to table: "gate_authorization_consumptions"
CREATE INDEX "ix_gate_authorization_consumptions__consume_status" ON "gates"."gate_authorization_consumptions" ("consume_status");
-- Create index "ix_gate_authorization_consumptions__correlation_id" to table: "gate_authorization_consumptions"
CREATE INDEX "ix_gate_authorization_consumptions__correlation_id" ON "gates"."gate_authorization_consumptions" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_gate_authorization_consumptions__exit_authorization_id" to table: "gate_authorization_consumptions"
CREATE INDEX "ix_gate_authorization_consumptions__exit_authorization_id" ON "gates"."gate_authorization_consumptions" ("exit_authorization_id");
-- Create index "ix_gate_authorization_consumptions__gate_device_id" to table: "gate_authorization_consumptions"
CREATE INDEX "ix_gate_authorization_consumptions__gate_device_id" ON "gates"."gate_authorization_consumptions" ("gate_device_id");
-- Create index "ix_gate_authorization_consumptions__lane_id" to table: "gate_authorization_consumptions"
CREATE INDEX "ix_gate_authorization_consumptions__lane_id" ON "gates"."gate_authorization_consumptions" ("lane_id");
-- Create index "ix_gate_authorization_consumptions__site_id" to table: "gate_authorization_consumptions"
CREATE INDEX "ix_gate_authorization_consumptions__site_id" ON "gates"."gate_authorization_consumptions" ("site_id");
-- Create index "ux_gate_auth_consumptions__successful_exit_auth" to table: "gate_authorization_consumptions"
CREATE UNIQUE INDEX "ux_gate_auth_consumptions__successful_exit_auth" ON "gates"."gate_authorization_consumptions" ("exit_authorization_id") WHERE (consume_status = 'CONSUMED'::gates.gate_authorization_consumption_status_enum);
-- Set comment to table: "gate_authorization_consumptions"
COMMENT ON TABLE "gates"."gate_authorization_consumptions" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "gate_authorization_consumption_id" on table: "gate_authorization_consumptions"
COMMENT ON COLUMN "gates"."gate_authorization_consumptions"."gate_authorization_consumption_id" IS 'Canonical identifier of the consume attempt.';
-- Set comment to column: "exit_authorization_id" on table: "gate_authorization_consumptions"
COMMENT ON COLUMN "gates"."gate_authorization_consumptions"."exit_authorization_id" IS 'Authorization presented or consumed, where known.';
-- Set comment to column: "authorization_token_hash" on table: "gate_authorization_consumptions"
COMMENT ON COLUMN "gates"."gate_authorization_consumptions"."authorization_token_hash" IS 'Hash of presented token where authorization ID is not yet known or for replay analysis.';
-- Set comment to column: "gate_device_id" on table: "gate_authorization_consumptions"
COMMENT ON COLUMN "gates"."gate_authorization_consumptions"."gate_device_id" IS 'Gate device involved in the consume attempt.';
-- Set comment to column: "site_id" on table: "gate_authorization_consumptions"
COMMENT ON COLUMN "gates"."gate_authorization_consumptions"."site_id" IS 'Site where consume attempt occurred.';
-- Set comment to column: "lane_id" on table: "gate_authorization_consumptions"
COMMENT ON COLUMN "gates"."gate_authorization_consumptions"."lane_id" IS 'Lane where consume attempt occurred.';
-- Set comment to column: "consume_status" on table: "gate_authorization_consumptions"
COMMENT ON COLUMN "gates"."gate_authorization_consumptions"."consume_status" IS 'Consume result.';
-- Set comment to column: "consume_reason_code" on table: "gate_authorization_consumptions"
COMMENT ON COLUMN "gates"."gate_authorization_consumptions"."consume_reason_code" IS 'Controlled reason for denial, failure, or exception.';
-- Set comment to column: "requested_at" on table: "gate_authorization_consumptions"
COMMENT ON COLUMN "gates"."gate_authorization_consumptions"."requested_at" IS 'Timestamp when consume request was received.';
-- Set comment to column: "validated_at" on table: "gate_authorization_consumptions"
COMMENT ON COLUMN "gates"."gate_authorization_consumptions"."validated_at" IS 'Timestamp when authorization validation completed.';
-- Set comment to column: "consumed_at" on table: "gate_authorization_consumptions"
COMMENT ON COLUMN "gates"."gate_authorization_consumptions"."consumed_at" IS 'Timestamp when authorization was consumed through the approved path.';
-- Set comment to column: "command_requested" on table: "gate_authorization_consumptions"
COMMENT ON COLUMN "gates"."gate_authorization_consumptions"."command_requested" IS 'Indicates whether gate-open command was requested after consume.';
-- Set comment to column: "command_result_status" on table: "gate_authorization_consumptions"
COMMENT ON COLUMN "gates"."gate_authorization_consumptions"."command_result_status" IS 'Result of gate-open command, if captured here.';
-- Set comment to column: "command_result_at" on table: "gate_authorization_consumptions"
COMMENT ON COLUMN "gates"."gate_authorization_consumptions"."command_result_at" IS 'Timestamp when command result was known.';
-- Set comment to column: "failure_detail" on table: "gate_authorization_consumptions"
COMMENT ON COLUMN "gates"."gate_authorization_consumptions"."failure_detail" IS 'Controlled troubleshooting detail.';
-- Set comment to column: "correlation_id" on table: "gate_authorization_consumptions"
COMMENT ON COLUMN "gates"."gate_authorization_consumptions"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "gate_authorization_consumptions"
COMMENT ON COLUMN "gates"."gate_authorization_consumptions"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_service_identity_id" on table: "gate_authorization_consumptions"
COMMENT ON COLUMN "gates"."gate_authorization_consumptions"."created_by_service_identity_id" IS 'Service identity that recorded the consume attempt.';
-- Set comment to column: "updated_at" on table: "gate_authorization_consumptions"
COMMENT ON COLUMN "gates"."gate_authorization_consumptions"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_service_identity_id" on table: "gate_authorization_consumptions"
COMMENT ON COLUMN "gates"."gate_authorization_consumptions"."updated_by_service_identity_id" IS 'Service identity that updated the consume record.';
-- Set comment to column: "row_version" on table: "gate_authorization_consumptions"
COMMENT ON COLUMN "gates"."gate_authorization_consumptions"."row_version" IS 'Optimistic concurrency version.';
-- Create "gate_devices" table
CREATE TABLE "gates"."gate_devices" (
  "gate_device_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "site_id" uuid NOT NULL,
  "lane_id" uuid NULL,
  "service_identity_id" uuid NULL,
  "device_code" character varying(64) NOT NULL,
  "device_name" character varying(128) NOT NULL,
  "device_type" "gates"."gate_device_type_enum" NOT NULL,
  "vendor_device_ref" character varying(128) NULL,
  "serial_number" character varying(128) NULL,
  "device_status" "gates"."gate_device_status_enum" NOT NULL,
  "installed_at" timestamptz NULL,
  "activated_at" timestamptz NULL,
  "retired_at" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_gate_devices" PRIMARY KEY ("gate_device_id"),
  CONSTRAINT "uq_gate_devices__site_device_code" UNIQUE ("site_id", "device_code")
);
-- Create index "ix_gate_devices__lane_id" to table: "gate_devices"
CREATE INDEX "ix_gate_devices__lane_id" ON "gates"."gate_devices" ("lane_id");
-- Create index "ix_gate_devices__service_identity_id" to table: "gate_devices"
CREATE INDEX "ix_gate_devices__service_identity_id" ON "gates"."gate_devices" ("service_identity_id");
-- Create index "ix_gate_devices__site_id" to table: "gate_devices"
CREATE INDEX "ix_gate_devices__site_id" ON "gates"."gate_devices" ("site_id");
-- Create index "ux_gate_devices__serial_number" to table: "gate_devices"
CREATE UNIQUE INDEX "ux_gate_devices__serial_number" ON "gates"."gate_devices" ("serial_number") WHERE (serial_number IS NOT NULL);
-- Create index "ux_gate_devices__service_identity" to table: "gate_devices"
CREATE UNIQUE INDEX "ux_gate_devices__service_identity" ON "gates"."gate_devices" ("service_identity_id") WHERE (service_identity_id IS NOT NULL);
-- Create index "ux_gate_devices__vendor_device_ref" to table: "gate_devices"
CREATE UNIQUE INDEX "ux_gate_devices__vendor_device_ref" ON "gates"."gate_devices" ("site_id", "vendor_device_ref") WHERE (vendor_device_ref IS NOT NULL);
-- Set comment to table: "gate_devices"
COMMENT ON TABLE "gates"."gate_devices" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "gate_device_id" on table: "gate_devices"
COMMENT ON COLUMN "gates"."gate_devices"."gate_device_id" IS 'Canonical identifier of the gate device.';
-- Set comment to column: "site_id" on table: "gate_devices"
COMMENT ON COLUMN "gates"."gate_devices"."site_id" IS 'Site where the device operates.';
-- Set comment to column: "lane_id" on table: "gate_devices"
COMMENT ON COLUMN "gates"."gate_devices"."lane_id" IS 'Lane where the device is assigned.';
-- Set comment to column: "service_identity_id" on table: "gate_devices"
COMMENT ON COLUMN "gates"."gate_devices"."service_identity_id" IS 'Authenticated service or device principal.';
-- Set comment to column: "device_code" on table: "gate_devices"
COMMENT ON COLUMN "gates"."gate_devices"."device_code" IS 'Stable internal device code.';
-- Set comment to column: "device_name" on table: "gate_devices"
COMMENT ON COLUMN "gates"."gate_devices"."device_name" IS 'Human-readable device name.';
-- Set comment to column: "device_type" on table: "gate_devices"
COMMENT ON COLUMN "gates"."gate_devices"."device_type" IS 'Device classification.';
-- Set comment to column: "vendor_device_ref" on table: "gate_devices"
COMMENT ON COLUMN "gates"."gate_devices"."vendor_device_ref" IS 'Vendor or controller reference for the device.';
-- Set comment to column: "serial_number" on table: "gate_devices"
COMMENT ON COLUMN "gates"."gate_devices"."serial_number" IS 'Manufacturer serial number where available.';
-- Set comment to column: "device_status" on table: "gate_devices"
COMMENT ON COLUMN "gates"."gate_devices"."device_status" IS 'Device lifecycle or operational status.';
-- Set comment to column: "installed_at" on table: "gate_devices"
COMMENT ON COLUMN "gates"."gate_devices"."installed_at" IS 'Installation timestamp.';
-- Set comment to column: "activated_at" on table: "gate_devices"
COMMENT ON COLUMN "gates"."gate_devices"."activated_at" IS 'Activation timestamp.';
-- Set comment to column: "retired_at" on table: "gate_devices"
COMMENT ON COLUMN "gates"."gate_devices"."retired_at" IS 'Retirement timestamp.';
-- Set comment to column: "created_at" on table: "gate_devices"
COMMENT ON COLUMN "gates"."gate_devices"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "gate_devices"
COMMENT ON COLUMN "gates"."gate_devices"."created_by_user_id" IS 'User who created the record.';
-- Set comment to column: "created_by_service_identity_id" on table: "gate_devices"
COMMENT ON COLUMN "gates"."gate_devices"."created_by_service_identity_id" IS 'Service identity that created the record.';
-- Set comment to column: "updated_at" on table: "gate_devices"
COMMENT ON COLUMN "gates"."gate_devices"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "gate_devices"
COMMENT ON COLUMN "gates"."gate_devices"."updated_by_user_id" IS 'User who last updated the record.';
-- Set comment to column: "updated_by_service_identity_id" on table: "gate_devices"
COMMENT ON COLUMN "gates"."gate_devices"."updated_by_service_identity_id" IS 'Service identity that last updated the record.';
-- Set comment to column: "row_version" on table: "gate_devices"
COMMENT ON COLUMN "gates"."gate_devices"."row_version" IS 'Optimistic concurrency version.';
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
);
-- Create index "ix_gate_events__correlation_id" to table: "gate_events"
CREATE INDEX "ix_gate_events__correlation_id" ON "gates"."gate_events" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_gate_events__event_status" to table: "gate_events"
CREATE INDEX "ix_gate_events__event_status" ON "gates"."gate_events" ("event_status");
-- Create index "ix_gate_events__exit_authorization_id" to table: "gate_events"
CREATE INDEX "ix_gate_events__exit_authorization_id" ON "gates"."gate_events" ("exit_authorization_id");
-- Create index "ix_gate_events__gate_device_id" to table: "gate_events"
CREATE INDEX "ix_gate_events__gate_device_id" ON "gates"."gate_events" ("gate_device_id");
-- Create index "ix_gate_events__lane_id" to table: "gate_events"
CREATE INDEX "ix_gate_events__lane_id" ON "gates"."gate_events" ("lane_id");
-- Create index "ix_gate_events__occurred_at" to table: "gate_events"
CREATE INDEX "ix_gate_events__occurred_at" ON "gates"."gate_events" ("occurred_at");
-- Create index "ix_gate_events__site_id" to table: "gate_events"
CREATE INDEX "ix_gate_events__site_id" ON "gates"."gate_events" ("site_id");
-- Set comment to table: "gate_events"
COMMENT ON TABLE "gates"."gate_events" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "gate_event_id" on table: "gate_events"
COMMENT ON COLUMN "gates"."gate_events"."gate_event_id" IS 'Canonical identifier of the gate event.';
-- Set comment to column: "gate_device_id" on table: "gate_events"
COMMENT ON COLUMN "gates"."gate_events"."gate_device_id" IS 'Gate device that emitted or was associated with the event.';
-- Set comment to column: "gate_authorization_consumption_id" on table: "gate_events"
COMMENT ON COLUMN "gates"."gate_events"."gate_authorization_consumption_id" IS 'Related authorization consume attempt.';
-- Set comment to column: "exit_authorization_id" on table: "gate_events"
COMMENT ON COLUMN "gates"."gate_events"."exit_authorization_id" IS 'Related exit authorization where applicable.';
-- Set comment to column: "site_id" on table: "gate_events"
COMMENT ON COLUMN "gates"."gate_events"."site_id" IS 'Site where the event occurred.';
-- Set comment to column: "lane_id" on table: "gate_events"
COMMENT ON COLUMN "gates"."gate_events"."lane_id" IS 'Lane where the event occurred.';
-- Set comment to column: "event_type" on table: "gate_events"
COMMENT ON COLUMN "gates"."gate_events"."event_type" IS 'Gate event type.';
-- Set comment to column: "event_status" on table: "gate_events"
COMMENT ON COLUMN "gates"."gate_events"."event_status" IS 'Event result or classification.';
-- Set comment to column: "event_reason_code" on table: "gate_events"
COMMENT ON COLUMN "gates"."gate_events"."event_reason_code" IS 'Controlled reason or classification.';
-- Set comment to column: "event_payload_ref" on table: "gate_events"
COMMENT ON COLUMN "gates"."gate_events"."event_payload_ref" IS 'Reference to detailed event payload if retained.';
-- Set comment to column: "event_payload_hash" on table: "gate_events"
COMMENT ON COLUMN "gates"."gate_events"."event_payload_hash" IS 'Hash of detailed payload where retained.';
-- Set comment to column: "source_event_ref" on table: "gate_events"
COMMENT ON COLUMN "gates"."gate_events"."source_event_ref" IS 'Vendor or device event reference where available.';
-- Set comment to column: "occurred_at" on table: "gate_events"
COMMENT ON COLUMN "gates"."gate_events"."occurred_at" IS 'Timestamp when event occurred or was observed.';
-- Set comment to column: "received_at" on table: "gate_events"
COMMENT ON COLUMN "gates"."gate_events"."received_at" IS 'Timestamp when ExitPass received or recorded the event.';
-- Set comment to column: "correlation_id" on table: "gate_events"
COMMENT ON COLUMN "gates"."gate_events"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "gate_events"
COMMENT ON COLUMN "gates"."gate_events"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_service_identity_id" on table: "gate_events"
COMMENT ON COLUMN "gates"."gate_events"."created_by_service_identity_id" IS 'Service identity that created the event.';
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
);
-- Create index "ix_gate_heartbeats__correlation_id" to table: "gate_heartbeats"
CREATE INDEX "ix_gate_heartbeats__correlation_id" ON "gates"."gate_heartbeats" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_gate_heartbeats__device_reported_status" to table: "gate_heartbeats"
CREATE INDEX "ix_gate_heartbeats__device_reported_status" ON "gates"."gate_heartbeats" ("device_reported_status");
-- Create index "ix_gate_heartbeats__gate_device_id" to table: "gate_heartbeats"
CREATE INDEX "ix_gate_heartbeats__gate_device_id" ON "gates"."gate_heartbeats" ("gate_device_id");
-- Create index "ix_gate_heartbeats__heartbeat_status" to table: "gate_heartbeats"
CREATE INDEX "ix_gate_heartbeats__heartbeat_status" ON "gates"."gate_heartbeats" ("heartbeat_status");
-- Create index "ix_gate_heartbeats__lane_id" to table: "gate_heartbeats"
CREATE INDEX "ix_gate_heartbeats__lane_id" ON "gates"."gate_heartbeats" ("lane_id");
-- Create index "ix_gate_heartbeats__observed_at" to table: "gate_heartbeats"
CREATE INDEX "ix_gate_heartbeats__observed_at" ON "gates"."gate_heartbeats" ("observed_at");
-- Create index "ix_gate_heartbeats__site_id" to table: "gate_heartbeats"
CREATE INDEX "ix_gate_heartbeats__site_id" ON "gates"."gate_heartbeats" ("site_id");
-- Set comment to table: "gate_heartbeats"
COMMENT ON TABLE "gates"."gate_heartbeats" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "gate_heartbeat_id" on table: "gate_heartbeats"
COMMENT ON COLUMN "gates"."gate_heartbeats"."gate_heartbeat_id" IS 'Canonical identifier of the heartbeat record.';
-- Set comment to column: "gate_device_id" on table: "gate_heartbeats"
COMMENT ON COLUMN "gates"."gate_heartbeats"."gate_device_id" IS 'Gate device that produced or is represented by the heartbeat.';
-- Set comment to column: "site_id" on table: "gate_heartbeats"
COMMENT ON COLUMN "gates"."gate_heartbeats"."site_id" IS 'Site where the device operates.';
-- Set comment to column: "lane_id" on table: "gate_heartbeats"
COMMENT ON COLUMN "gates"."gate_heartbeats"."lane_id" IS 'Lane where the device operates.';
-- Set comment to column: "heartbeat_status" on table: "gate_heartbeats"
COMMENT ON COLUMN "gates"."gate_heartbeats"."heartbeat_status" IS 'Health status.';
-- Set comment to column: "device_reported_status" on table: "gate_heartbeats"
COMMENT ON COLUMN "gates"."gate_heartbeats"."device_reported_status" IS 'Native status from device or adapter.';
-- Set comment to column: "latency_ms" on table: "gate_heartbeats"
COMMENT ON COLUMN "gates"."gate_heartbeats"."latency_ms" IS 'Measured latency in milliseconds.';
-- Set comment to column: "error_code" on table: "gate_heartbeats"
COMMENT ON COLUMN "gates"."gate_heartbeats"."error_code" IS 'Device or adapter error code.';
-- Set comment to column: "error_detail" on table: "gate_heartbeats"
COMMENT ON COLUMN "gates"."gate_heartbeats"."error_detail" IS 'Controlled error detail or diagnostic note.';
-- Set comment to column: "observed_at" on table: "gate_heartbeats"
COMMENT ON COLUMN "gates"."gate_heartbeats"."observed_at" IS 'Timestamp when health was observed.';
-- Set comment to column: "received_at" on table: "gate_heartbeats"
COMMENT ON COLUMN "gates"."gate_heartbeats"."received_at" IS 'Timestamp when ExitPass recorded heartbeat.';
-- Set comment to column: "correlation_id" on table: "gate_heartbeats"
COMMENT ON COLUMN "gates"."gate_heartbeats"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "gate_heartbeats"
COMMENT ON COLUMN "gates"."gate_heartbeats"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_service_identity_id" on table: "gate_heartbeats"
COMMENT ON COLUMN "gates"."gate_heartbeats"."created_by_service_identity_id" IS 'Service identity that recorded the heartbeat.';
-- Create enum type "permission_status_enum"
CREATE TYPE "identity"."permission_status_enum" AS ENUM ('DRAFT', 'ACTIVE', 'DEPRECATED', 'RETIRED');
-- Create enum type "role_permission_binding_status_enum"
CREATE TYPE "identity"."role_permission_binding_status_enum" AS ENUM ('ACTIVE', 'SUSPENDED', 'REVOKED', 'EXPIRED', 'RETIRED');
-- Create enum type "role_status_enum"
CREATE TYPE "identity"."role_status_enum" AS ENUM ('DRAFT', 'ACTIVE', 'SUSPENDED', 'RETIRED');
-- Create enum type "role_type_enum"
CREATE TYPE "identity"."role_type_enum" AS ENUM ('SYSTEM', 'OPERATIONS', 'MERCHANT', 'FINANCE', 'COMPLIANCE', 'SUPPORT', 'SECURITY', 'SERVICE', 'OTHER');
-- Create enum type "service_credential_type_enum"
CREATE TYPE "identity"."service_credential_type_enum" AS ENUM ('CLIENT_SECRET_REFERENCE', 'CERTIFICATE_REFERENCE', 'MTLS_CERTIFICATE_REFERENCE', 'API_KEY_REFERENCE', 'JWT_SIGNING_KEY_REFERENCE', 'KEY_VAULT_REFERENCE', 'WEBHOOK_SECRET_REFERENCE', 'NONE');
-- Create enum type "service_identity_status_enum"
CREATE TYPE "identity"."service_identity_status_enum" AS ENUM ('DRAFT', 'ACTIVE', 'SUSPENDED', 'REVOKED', 'EXPIRED', 'RETIRED');
-- Create enum type "service_identity_type_enum"
CREATE TYPE "identity"."service_identity_type_enum" AS ENUM ('INTERNAL_SERVICE', 'EXTERNAL_CLIENT', 'ADAPTER', 'BACKGROUND_WORKER', 'SCHEDULED_JOB', 'WEBHOOK_RECEIVER', 'DEVICE', 'GATEWAY', 'OTHER');
-- Create enum type "user_role_assignment_status_enum"
CREATE TYPE "identity"."user_role_assignment_status_enum" AS ENUM ('ACTIVE', 'SUSPENDED', 'REVOKED', 'EXPIRED', 'RETIRED');
-- Create enum type "user_status_enum"
CREATE TYPE "identity"."user_status_enum" AS ENUM ('INVITED', 'ACTIVE', 'LOCKED', 'SUSPENDED', 'INACTIVE', 'RETIRED');
-- Create enum type "user_type_enum"
CREATE TYPE "identity"."user_type_enum" AS ENUM ('INTERNAL_ADMIN', 'OPERATIONS_USER', 'SITE_OPERATOR', 'SUPPORT_USER', 'FINANCE_USER', 'COMPLIANCE_USER', 'MERCHANT_USER', 'SECURITY_USER', 'OTHER');
-- Create "permissions" table
CREATE TABLE "identity"."permissions" (
  "permission_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "permission_code" character varying(96) NOT NULL,
  "permission_name" character varying(128) NOT NULL,
  "permission_description" text NULL,
  "permission_domain" character varying(64) NOT NULL,
  "permission_action" character varying(64) NOT NULL,
  "permission_status" "identity"."permission_status_enum" NOT NULL,
  "is_sensitive" boolean NOT NULL DEFAULT false,
  "requires_audit" boolean NOT NULL DEFAULT false,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_permissions" PRIMARY KEY ("permission_id"),
  CONSTRAINT "uq_permissions__permission_code" UNIQUE ("permission_code")
);
-- Create index "ix_permissions__permission_status" to table: "permissions"
CREATE INDEX "ix_permissions__permission_status" ON "identity"."permissions" ("permission_status");
-- Set comment to table: "permissions"
COMMENT ON TABLE "identity"."permissions" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "permission_id" on table: "permissions"
COMMENT ON COLUMN "identity"."permissions"."permission_id" IS 'Canonical identifier of the permission.';
-- Set comment to column: "permission_code" on table: "permissions"
COMMENT ON COLUMN "identity"."permissions"."permission_code" IS 'Stable permission code.';
-- Set comment to column: "permission_name" on table: "permissions"
COMMENT ON COLUMN "identity"."permissions"."permission_name" IS 'Human-readable permission name.';
-- Set comment to column: "permission_description" on table: "permissions"
COMMENT ON COLUMN "identity"."permissions"."permission_description" IS 'Description of the permission.';
-- Set comment to column: "permission_domain" on table: "permissions"
COMMENT ON COLUMN "identity"."permissions"."permission_domain" IS 'Domain or schema to which the permission belongs.';
-- Set comment to column: "permission_action" on table: "permissions"
COMMENT ON COLUMN "identity"."permissions"."permission_action" IS 'Action category.';
-- Set comment to column: "permission_status" on table: "permissions"
COMMENT ON COLUMN "identity"."permissions"."permission_status" IS 'Permission lifecycle status.';
-- Set comment to column: "is_sensitive" on table: "permissions"
COMMENT ON COLUMN "identity"."permissions"."is_sensitive" IS 'Indicates whether the permission grants sensitive access.';
-- Set comment to column: "requires_audit" on table: "permissions"
COMMENT ON COLUMN "identity"."permissions"."requires_audit" IS 'Indicates whether use of the permission should be auditable.';
-- Set comment to column: "created_at" on table: "permissions"
COMMENT ON COLUMN "identity"."permissions"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "permissions"
COMMENT ON COLUMN "identity"."permissions"."created_by_user_id" IS 'User who created the permission.';
-- Set comment to column: "created_by_service_identity_id" on table: "permissions"
COMMENT ON COLUMN "identity"."permissions"."created_by_service_identity_id" IS 'Service identity that created the permission.';
-- Set comment to column: "updated_at" on table: "permissions"
COMMENT ON COLUMN "identity"."permissions"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "permissions"
COMMENT ON COLUMN "identity"."permissions"."updated_by_user_id" IS 'User who last updated the permission.';
-- Set comment to column: "updated_by_service_identity_id" on table: "permissions"
COMMENT ON COLUMN "identity"."permissions"."updated_by_service_identity_id" IS 'Service identity that last updated the permission.';
-- Set comment to column: "row_version" on table: "permissions"
COMMENT ON COLUMN "identity"."permissions"."row_version" IS 'Optimistic concurrency version.';
-- Create "role_permissions" table
CREATE TABLE "identity"."role_permissions" (
  "role_permission_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "role_id" uuid NOT NULL,
  "permission_id" uuid NOT NULL,
  "binding_status" "identity"."role_permission_binding_status_enum" NOT NULL,
  "binding_reason_code" character varying(64) NULL,
  "assigned_at" timestamptz NOT NULL DEFAULT now(),
  "assigned_by_user_id" uuid NULL,
  "assigned_by_service_identity_id" uuid NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "revoked_at" timestamptz NULL,
  "revoked_by_user_id" uuid NULL,
  "revoked_by_service_identity_id" uuid NULL,
  "revocation_reason_code" character varying(64) NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_role_permissions" PRIMARY KEY ("role_permission_id")
);
-- Create index "ix_role_permissions__assigned_by_user_id" to table: "role_permissions"
CREATE INDEX "ix_role_permissions__assigned_by_user_id" ON "identity"."role_permissions" ("assigned_by_user_id");
-- Create index "ix_role_permissions__permission_id" to table: "role_permissions"
CREATE INDEX "ix_role_permissions__permission_id" ON "identity"."role_permissions" ("permission_id");
-- Create index "ix_role_permissions__role_id" to table: "role_permissions"
CREATE INDEX "ix_role_permissions__role_id" ON "identity"."role_permissions" ("role_id");
-- Create index "ux_role_permissions__active_role_permission" to table: "role_permissions"
CREATE UNIQUE INDEX "ux_role_permissions__active_role_permission" ON "identity"."role_permissions" ("role_id", "permission_id") WHERE (binding_status = 'ACTIVE'::identity.role_permission_binding_status_enum);
-- Set comment to table: "role_permissions"
COMMENT ON TABLE "identity"."role_permissions" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "role_permission_id" on table: "role_permissions"
COMMENT ON COLUMN "identity"."role_permissions"."role_permission_id" IS 'Canonical identifier of the role-permission binding.';
-- Set comment to column: "role_id" on table: "role_permissions"
COMMENT ON COLUMN "identity"."role_permissions"."role_id" IS 'Role receiving the permission.';
-- Set comment to column: "permission_id" on table: "role_permissions"
COMMENT ON COLUMN "identity"."role_permissions"."permission_id" IS 'Permission assigned to the role.';
-- Set comment to column: "binding_status" on table: "role_permissions"
COMMENT ON COLUMN "identity"."role_permissions"."binding_status" IS 'Binding lifecycle status.';
-- Set comment to column: "binding_reason_code" on table: "role_permissions"
COMMENT ON COLUMN "identity"."role_permissions"."binding_reason_code" IS 'Controlled reason for binding.';
-- Set comment to column: "assigned_at" on table: "role_permissions"
COMMENT ON COLUMN "identity"."role_permissions"."assigned_at" IS 'Timestamp when permission binding was assigned.';
-- Set comment to column: "assigned_by_user_id" on table: "role_permissions"
COMMENT ON COLUMN "identity"."role_permissions"."assigned_by_user_id" IS 'User who assigned the permission to the role.';
-- Set comment to column: "assigned_by_service_identity_id" on table: "role_permissions"
COMMENT ON COLUMN "identity"."role_permissions"."assigned_by_service_identity_id" IS 'Service identity that assigned the permission.';
-- Set comment to column: "effective_from" on table: "role_permissions"
COMMENT ON COLUMN "identity"."role_permissions"."effective_from" IS 'Start of binding effectiveness.';
-- Set comment to column: "effective_to" on table: "role_permissions"
COMMENT ON COLUMN "identity"."role_permissions"."effective_to" IS 'End of binding effectiveness.';
-- Set comment to column: "revoked_at" on table: "role_permissions"
COMMENT ON COLUMN "identity"."role_permissions"."revoked_at" IS 'Timestamp when permission binding was revoked.';
-- Set comment to column: "revoked_by_user_id" on table: "role_permissions"
COMMENT ON COLUMN "identity"."role_permissions"."revoked_by_user_id" IS 'User who revoked the binding.';
-- Set comment to column: "revoked_by_service_identity_id" on table: "role_permissions"
COMMENT ON COLUMN "identity"."role_permissions"."revoked_by_service_identity_id" IS 'Service identity that revoked the binding.';
-- Set comment to column: "revocation_reason_code" on table: "role_permissions"
COMMENT ON COLUMN "identity"."role_permissions"."revocation_reason_code" IS 'Controlled reason for revocation.';
-- Set comment to column: "created_at" on table: "role_permissions"
COMMENT ON COLUMN "identity"."role_permissions"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "role_permissions"
COMMENT ON COLUMN "identity"."role_permissions"."created_by_user_id" IS 'User who created the binding.';
-- Set comment to column: "created_by_service_identity_id" on table: "role_permissions"
COMMENT ON COLUMN "identity"."role_permissions"."created_by_service_identity_id" IS 'Service identity that created the binding.';
-- Set comment to column: "updated_at" on table: "role_permissions"
COMMENT ON COLUMN "identity"."role_permissions"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "role_permissions"
COMMENT ON COLUMN "identity"."role_permissions"."updated_by_user_id" IS 'User who last updated the binding.';
-- Set comment to column: "updated_by_service_identity_id" on table: "role_permissions"
COMMENT ON COLUMN "identity"."role_permissions"."updated_by_service_identity_id" IS 'Service identity that last updated the binding.';
-- Set comment to column: "row_version" on table: "role_permissions"
COMMENT ON COLUMN "identity"."role_permissions"."row_version" IS 'Optimistic concurrency version.';
-- Create "roles" table
CREATE TABLE "identity"."roles" (
  "role_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "role_code" character varying(64) NOT NULL,
  "role_name" character varying(128) NOT NULL,
  "role_description" text NULL,
  "role_type" "identity"."role_type_enum" NOT NULL,
  "role_status" "identity"."role_status_enum" NOT NULL,
  "is_privileged" boolean NOT NULL DEFAULT false,
  "requires_elevated_approval" boolean NOT NULL DEFAULT false,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_roles" PRIMARY KEY ("role_id"),
  CONSTRAINT "uq_roles__role_code" UNIQUE ("role_code")
);
-- Create index "ix_roles__role_status" to table: "roles"
CREATE INDEX "ix_roles__role_status" ON "identity"."roles" ("role_status");
-- Set comment to table: "roles"
COMMENT ON TABLE "identity"."roles" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "role_id" on table: "roles"
COMMENT ON COLUMN "identity"."roles"."role_id" IS 'Canonical identifier of the role.';
-- Set comment to column: "role_code" on table: "roles"
COMMENT ON COLUMN "identity"."roles"."role_code" IS 'Stable role code.';
-- Set comment to column: "role_name" on table: "roles"
COMMENT ON COLUMN "identity"."roles"."role_name" IS 'Human-readable role name.';
-- Set comment to column: "role_description" on table: "roles"
COMMENT ON COLUMN "identity"."roles"."role_description" IS 'Description of the role.';
-- Set comment to column: "role_type" on table: "roles"
COMMENT ON COLUMN "identity"."roles"."role_type" IS 'Role classification.';
-- Set comment to column: "role_status" on table: "roles"
COMMENT ON COLUMN "identity"."roles"."role_status" IS 'Role lifecycle status.';
-- Set comment to column: "is_privileged" on table: "roles"
COMMENT ON COLUMN "identity"."roles"."is_privileged" IS 'Indicates whether the role grants privileged or sensitive access.';
-- Set comment to column: "requires_elevated_approval" on table: "roles"
COMMENT ON COLUMN "identity"."roles"."requires_elevated_approval" IS 'Indicates whether assignment requires elevated approval.';
-- Set comment to column: "effective_from" on table: "roles"
COMMENT ON COLUMN "identity"."roles"."effective_from" IS 'Start of role effectiveness.';
-- Set comment to column: "effective_to" on table: "roles"
COMMENT ON COLUMN "identity"."roles"."effective_to" IS 'End of role effectiveness.';
-- Set comment to column: "created_at" on table: "roles"
COMMENT ON COLUMN "identity"."roles"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "roles"
COMMENT ON COLUMN "identity"."roles"."created_by_user_id" IS 'User who created the role.';
-- Set comment to column: "created_by_service_identity_id" on table: "roles"
COMMENT ON COLUMN "identity"."roles"."created_by_service_identity_id" IS 'Service identity that created the role.';
-- Set comment to column: "updated_at" on table: "roles"
COMMENT ON COLUMN "identity"."roles"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "roles"
COMMENT ON COLUMN "identity"."roles"."updated_by_user_id" IS 'User who last updated the role.';
-- Set comment to column: "updated_by_service_identity_id" on table: "roles"
COMMENT ON COLUMN "identity"."roles"."updated_by_service_identity_id" IS 'Service identity that last updated the role.';
-- Set comment to column: "row_version" on table: "roles"
COMMENT ON COLUMN "identity"."roles"."row_version" IS 'Optimistic concurrency version.';
-- Create "service_identities" table
CREATE TABLE "identity"."service_identities" (
  "service_identity_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "service_identity_code" character varying(64) NOT NULL,
  "service_identity_name" character varying(128) NOT NULL,
  "identity_type" "identity"."service_identity_type_enum" NOT NULL,
  "identity_status" "identity"."service_identity_status_enum" NOT NULL,
  "owning_service_name" character varying(128) NULL,
  "credential_reference" character varying(256) NULL,
  "credential_type" "identity"."service_credential_type_enum" NULL,
  "credential_expires_at" timestamptz NULL,
  "last_rotated_at" timestamptz NULL,
  "last_authenticated_at" timestamptz NULL,
  "revoked_at" timestamptz NULL,
  "revocation_reason_code" character varying(64) NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_service_identities" PRIMARY KEY ("service_identity_id"),
  CONSTRAINT "uq_service_identities__service_identity_code" UNIQUE ("service_identity_code")
);
-- Create index "ix_service_identities__credential_expires_at" to table: "service_identities"
CREATE INDEX "ix_service_identities__credential_expires_at" ON "identity"."service_identities" ("credential_expires_at");
-- Create index "ix_service_identities__identity_status" to table: "service_identities"
CREATE INDEX "ix_service_identities__identity_status" ON "identity"."service_identities" ("identity_status");
-- Create index "ix_service_identities__last_rotated_at" to table: "service_identities"
CREATE INDEX "ix_service_identities__last_rotated_at" ON "identity"."service_identities" ("last_rotated_at");
-- Set comment to table: "service_identities"
COMMENT ON TABLE "identity"."service_identities" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "service_identity_id" on table: "service_identities"
COMMENT ON COLUMN "identity"."service_identities"."service_identity_id" IS 'Canonical identifier of the service identity.';
-- Set comment to column: "service_identity_code" on table: "service_identities"
COMMENT ON COLUMN "identity"."service_identities"."service_identity_code" IS 'Stable internal service identity code.';
-- Set comment to column: "service_identity_name" on table: "service_identities"
COMMENT ON COLUMN "identity"."service_identities"."service_identity_name" IS 'Human-readable service identity name.';
-- Set comment to column: "identity_type" on table: "service_identities"
COMMENT ON COLUMN "identity"."service_identities"."identity_type" IS 'Type of non-human principal.';
-- Set comment to column: "identity_status" on table: "service_identities"
COMMENT ON COLUMN "identity"."service_identities"."identity_status" IS 'Service identity lifecycle status.';
-- Set comment to column: "owning_service_name" on table: "service_identities"
COMMENT ON COLUMN "identity"."service_identities"."owning_service_name" IS 'Owning service, worker, adapter, or component name.';
-- Set comment to column: "credential_reference" on table: "service_identities"
COMMENT ON COLUMN "identity"."service_identities"."credential_reference" IS 'Reference to secret, certificate, key vault entry, or credential profile.';
-- Set comment to column: "credential_type" on table: "service_identities"
COMMENT ON COLUMN "identity"."service_identities"."credential_type" IS 'Credential type used by the service identity.';
-- Set comment to column: "credential_expires_at" on table: "service_identities"
COMMENT ON COLUMN "identity"."service_identities"."credential_expires_at" IS 'Credential expiry timestamp, where applicable.';
-- Set comment to column: "last_rotated_at" on table: "service_identities"
COMMENT ON COLUMN "identity"."service_identities"."last_rotated_at" IS 'Last credential rotation timestamp.';
-- Set comment to column: "last_authenticated_at" on table: "service_identities"
COMMENT ON COLUMN "identity"."service_identities"."last_authenticated_at" IS 'Last successful authentication timestamp.';
-- Set comment to column: "revoked_at" on table: "service_identities"
COMMENT ON COLUMN "identity"."service_identities"."revoked_at" IS 'Timestamp when identity was revoked.';
-- Set comment to column: "revocation_reason_code" on table: "service_identities"
COMMENT ON COLUMN "identity"."service_identities"."revocation_reason_code" IS 'Controlled revocation reason.';
-- Set comment to column: "effective_from" on table: "service_identities"
COMMENT ON COLUMN "identity"."service_identities"."effective_from" IS 'Start of service identity effectiveness.';
-- Set comment to column: "effective_to" on table: "service_identities"
COMMENT ON COLUMN "identity"."service_identities"."effective_to" IS 'End of service identity effectiveness.';
-- Set comment to column: "created_at" on table: "service_identities"
COMMENT ON COLUMN "identity"."service_identities"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "service_identities"
COMMENT ON COLUMN "identity"."service_identities"."created_by_user_id" IS 'User who created the service identity.';
-- Set comment to column: "created_by_service_identity_id" on table: "service_identities"
COMMENT ON COLUMN "identity"."service_identities"."created_by_service_identity_id" IS 'Service identity that created this service identity.';
-- Set comment to column: "updated_at" on table: "service_identities"
COMMENT ON COLUMN "identity"."service_identities"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "service_identities"
COMMENT ON COLUMN "identity"."service_identities"."updated_by_user_id" IS 'User who last updated the service identity.';
-- Set comment to column: "updated_by_service_identity_id" on table: "service_identities"
COMMENT ON COLUMN "identity"."service_identities"."updated_by_service_identity_id" IS 'Service identity that last updated this service identity.';
-- Set comment to column: "row_version" on table: "service_identities"
COMMENT ON COLUMN "identity"."service_identities"."row_version" IS 'Optimistic concurrency version.';
-- Create "user_roles" table
CREATE TABLE "identity"."user_roles" (
  "user_role_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "user_id" uuid NOT NULL,
  "role_id" uuid NOT NULL,
  "assignment_status" "identity"."user_role_assignment_status_enum" NOT NULL,
  "assignment_reason_code" character varying(64) NULL,
  "assigned_at" timestamptz NOT NULL DEFAULT now(),
  "assigned_by_user_id" uuid NULL,
  "assigned_by_service_identity_id" uuid NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "revoked_at" timestamptz NULL,
  "revoked_by_user_id" uuid NULL,
  "revoked_by_service_identity_id" uuid NULL,
  "revocation_reason_code" character varying(64) NULL,
  "last_reviewed_at" timestamptz NULL,
  "last_reviewed_by_user_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_user_roles" PRIMARY KEY ("user_role_id")
);
-- Create index "ix_user_roles__assigned_by_user_id" to table: "user_roles"
CREATE INDEX "ix_user_roles__assigned_by_user_id" ON "identity"."user_roles" ("assigned_by_user_id");
-- Create index "ix_user_roles__role_id" to table: "user_roles"
CREATE INDEX "ix_user_roles__role_id" ON "identity"."user_roles" ("role_id");
-- Create index "ix_user_roles__user_id" to table: "user_roles"
CREATE INDEX "ix_user_roles__user_id" ON "identity"."user_roles" ("user_id");
-- Create index "ux_user_roles__active_user_role" to table: "user_roles"
CREATE UNIQUE INDEX "ux_user_roles__active_user_role" ON "identity"."user_roles" ("user_id", "role_id") WHERE (assignment_status = 'ACTIVE'::identity.user_role_assignment_status_enum);
-- Set comment to table: "user_roles"
COMMENT ON TABLE "identity"."user_roles" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "user_role_id" on table: "user_roles"
COMMENT ON COLUMN "identity"."user_roles"."user_role_id" IS 'Canonical identifier of the user-role assignment.';
-- Set comment to column: "user_id" on table: "user_roles"
COMMENT ON COLUMN "identity"."user_roles"."user_id" IS 'User receiving the role.';
-- Set comment to column: "role_id" on table: "user_roles"
COMMENT ON COLUMN "identity"."user_roles"."role_id" IS 'Role assigned to the user.';
-- Set comment to column: "assignment_status" on table: "user_roles"
COMMENT ON COLUMN "identity"."user_roles"."assignment_status" IS 'Assignment lifecycle status.';
-- Set comment to column: "assignment_reason_code" on table: "user_roles"
COMMENT ON COLUMN "identity"."user_roles"."assignment_reason_code" IS 'Controlled reason for assignment.';
-- Set comment to column: "assigned_at" on table: "user_roles"
COMMENT ON COLUMN "identity"."user_roles"."assigned_at" IS 'Timestamp when role assignment became effective or was created.';
-- Set comment to column: "assigned_by_user_id" on table: "user_roles"
COMMENT ON COLUMN "identity"."user_roles"."assigned_by_user_id" IS 'User who assigned the role.';
-- Set comment to column: "assigned_by_service_identity_id" on table: "user_roles"
COMMENT ON COLUMN "identity"."user_roles"."assigned_by_service_identity_id" IS 'Service identity that assigned the role.';
-- Set comment to column: "effective_from" on table: "user_roles"
COMMENT ON COLUMN "identity"."user_roles"."effective_from" IS 'Start of role assignment effectiveness.';
-- Set comment to column: "effective_to" on table: "user_roles"
COMMENT ON COLUMN "identity"."user_roles"."effective_to" IS 'End of role assignment effectiveness.';
-- Set comment to column: "revoked_at" on table: "user_roles"
COMMENT ON COLUMN "identity"."user_roles"."revoked_at" IS 'Timestamp when assignment was revoked.';
-- Set comment to column: "revoked_by_user_id" on table: "user_roles"
COMMENT ON COLUMN "identity"."user_roles"."revoked_by_user_id" IS 'User who revoked the assignment.';
-- Set comment to column: "revoked_by_service_identity_id" on table: "user_roles"
COMMENT ON COLUMN "identity"."user_roles"."revoked_by_service_identity_id" IS 'Service identity that revoked the assignment.';
-- Set comment to column: "revocation_reason_code" on table: "user_roles"
COMMENT ON COLUMN "identity"."user_roles"."revocation_reason_code" IS 'Controlled reason for revocation.';
-- Set comment to column: "last_reviewed_at" on table: "user_roles"
COMMENT ON COLUMN "identity"."user_roles"."last_reviewed_at" IS 'Last access-review timestamp.';
-- Set comment to column: "last_reviewed_by_user_id" on table: "user_roles"
COMMENT ON COLUMN "identity"."user_roles"."last_reviewed_by_user_id" IS 'User who reviewed the assignment.';
-- Set comment to column: "created_at" on table: "user_roles"
COMMENT ON COLUMN "identity"."user_roles"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "user_roles"
COMMENT ON COLUMN "identity"."user_roles"."created_by_user_id" IS 'User who created the assignment.';
-- Set comment to column: "created_by_service_identity_id" on table: "user_roles"
COMMENT ON COLUMN "identity"."user_roles"."created_by_service_identity_id" IS 'Service identity that created the assignment.';
-- Set comment to column: "updated_at" on table: "user_roles"
COMMENT ON COLUMN "identity"."user_roles"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "user_roles"
COMMENT ON COLUMN "identity"."user_roles"."updated_by_user_id" IS 'User who last updated the assignment.';
-- Set comment to column: "updated_by_service_identity_id" on table: "user_roles"
COMMENT ON COLUMN "identity"."user_roles"."updated_by_service_identity_id" IS 'Service identity that last updated the assignment.';
-- Set comment to column: "row_version" on table: "user_roles"
COMMENT ON COLUMN "identity"."user_roles"."row_version" IS 'Optimistic concurrency version.';
-- Create "users" table
CREATE TABLE "identity"."users" (
  "user_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "username" character varying(128) NOT NULL,
  "email" character varying(256) NULL,
  "email_normalized" character varying(256) NULL,
  "display_name" character varying(128) NOT NULL,
  "mobile_number_masked" character varying(32) NULL,
  "user_type" "identity"."user_type_enum" NOT NULL,
  "user_status" "identity"."user_status_enum" NOT NULL,
  "last_login_at" timestamptz NULL,
  "locked_at" timestamptz NULL,
  "suspended_at" timestamptz NULL,
  "retired_at" timestamptz NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_users" PRIMARY KEY ("user_id")
);
-- Create index "ix_users__last_login_at" to table: "users"
CREATE INDEX "ix_users__last_login_at" ON "identity"."users" ("last_login_at");
-- Create index "ix_users__locked_at" to table: "users"
CREATE INDEX "ix_users__locked_at" ON "identity"."users" ("locked_at");
-- Create index "ix_users__user_status" to table: "users"
CREATE INDEX "ix_users__user_status" ON "identity"."users" ("user_status");
-- Set comment to table: "users"
COMMENT ON TABLE "identity"."users" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "user_id" on table: "users"
COMMENT ON COLUMN "identity"."users"."user_id" IS 'Canonical identifier of the human user.';
-- Set comment to column: "username" on table: "users"
COMMENT ON COLUMN "identity"."users"."username" IS 'Stable login or platform username.';
-- Set comment to column: "email" on table: "users"
COMMENT ON COLUMN "identity"."users"."email" IS 'User email address.';
-- Set comment to column: "email_normalized" on table: "users"
COMMENT ON COLUMN "identity"."users"."email_normalized" IS 'Normalized email for uniqueness and lookup.';
-- Set comment to column: "display_name" on table: "users"
COMMENT ON COLUMN "identity"."users"."display_name" IS 'Human-readable display name.';
-- Set comment to column: "mobile_number_masked" on table: "users"
COMMENT ON COLUMN "identity"."users"."mobile_number_masked" IS 'Masked mobile number where retained.';
-- Set comment to column: "user_type" on table: "users"
COMMENT ON COLUMN "identity"."users"."user_type" IS 'User classification.';
-- Set comment to column: "user_status" on table: "users"
COMMENT ON COLUMN "identity"."users"."user_status" IS 'User lifecycle status.';
-- Set comment to column: "last_login_at" on table: "users"
COMMENT ON COLUMN "identity"."users"."last_login_at" IS 'Last successful login timestamp.';
-- Set comment to column: "locked_at" on table: "users"
COMMENT ON COLUMN "identity"."users"."locked_at" IS 'Timestamp when user was locked, if applicable.';
-- Set comment to column: "suspended_at" on table: "users"
COMMENT ON COLUMN "identity"."users"."suspended_at" IS 'Timestamp when user was suspended, if applicable.';
-- Set comment to column: "retired_at" on table: "users"
COMMENT ON COLUMN "identity"."users"."retired_at" IS 'Timestamp when user was retired.';
-- Set comment to column: "effective_from" on table: "users"
COMMENT ON COLUMN "identity"."users"."effective_from" IS 'Start of user effectiveness.';
-- Set comment to column: "effective_to" on table: "users"
COMMENT ON COLUMN "identity"."users"."effective_to" IS 'End of user effectiveness.';
-- Set comment to column: "created_at" on table: "users"
COMMENT ON COLUMN "identity"."users"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "users"
COMMENT ON COLUMN "identity"."users"."created_by_user_id" IS 'User who created the user record.';
-- Set comment to column: "created_by_service_identity_id" on table: "users"
COMMENT ON COLUMN "identity"."users"."created_by_service_identity_id" IS 'Service identity that created the user record.';
-- Set comment to column: "updated_at" on table: "users"
COMMENT ON COLUMN "identity"."users"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "users"
COMMENT ON COLUMN "identity"."users"."updated_by_user_id" IS 'User who last updated the user record.';
-- Set comment to column: "updated_by_service_identity_id" on table: "users"
COMMENT ON COLUMN "identity"."users"."updated_by_service_identity_id" IS 'Service identity that last updated the user record.';
-- Set comment to column: "row_version" on table: "users"
COMMENT ON COLUMN "identity"."users"."row_version" IS 'Optimistic concurrency version.';
-- Create enum type "adapter_mapping_confidence_enum"
CREATE TYPE "integration"."adapter_mapping_confidence_enum" AS ENUM ('MANUAL_APPROVED', 'IMPORTED_APPROVED', 'SYSTEM_DISCOVERED', 'LOW_CONFIDENCE', 'UNKNOWN');
-- Create enum type "adapter_mapping_status_enum"
CREATE TYPE "integration"."adapter_mapping_status_enum" AS ENUM ('DRAFT', 'ACTIVE', 'SUSPENDED', 'SUPERSEDED', 'RETIRED');
-- Create enum type "adapter_mapping_type_enum"
CREATE TYPE "integration"."adapter_mapping_type_enum" AS ENUM ('SITE_GROUP', 'SITE', 'LANE', 'GATE_DEVICE', 'PAYMENT_RAIL', 'TARIFF_GROUP', 'VENDOR_LOCATION', 'OTHER');
-- Create enum type "http_method_enum"
CREATE TYPE "integration"."http_method_enum" AS ENUM ('GET', 'POST', 'PUT', 'PATCH', 'DELETE');
-- Create enum type "integration_credential_status_enum"
CREATE TYPE "integration"."integration_credential_status_enum" AS ENUM ('DRAFT', 'ACTIVE', 'ROTATION_DUE', 'EXPIRED', 'REVOKED', 'RETIRED');
-- Create enum type "integration_credential_type_enum"
CREATE TYPE "integration"."integration_credential_type_enum" AS ENUM ('API_KEY_REFERENCE', 'CLIENT_SECRET_REFERENCE', 'OAUTH_CLIENT_REFERENCE', 'MTLS_CERTIFICATE_REFERENCE', 'SIGNING_KEY_REFERENCE', 'WEBHOOK_SECRET_REFERENCE', 'BASIC_AUTH_REFERENCE', 'OTHER');
-- Create enum type "integration_health_check_type_enum"
CREATE TYPE "integration"."integration_health_check_type_enum" AS ENUM ('SCHEDULED_HEALTH_CHECK', 'ON_DEMAND_CHECK', 'REQUEST_FAILURE', 'CALLBACK_FAILURE', 'LATENCY_OBSERVATION', 'RECOVERY_OBSERVATION', 'MANUAL_OBSERVATION');
-- Create enum type "integration_health_status_enum"
CREATE TYPE "integration"."integration_health_status_enum" AS ENUM ('AVAILABLE', 'DEGRADED', 'UNAVAILABLE', 'ERROR', 'UNKNOWN');
-- Create enum type "secret_store_type_enum"
CREATE TYPE "integration"."secret_store_type_enum" AS ENUM ('KEY_VAULT', 'SECRETS_MANAGER', 'CERTIFICATE_STORE', 'HSM', 'ENVIRONMENT_REFERENCE', 'OTHER');
-- Create enum type "vendor_endpoint_status_enum"
CREATE TYPE "integration"."vendor_endpoint_status_enum" AS ENUM ('DRAFT', 'ACTIVE', 'MAINTENANCE', 'SUSPENDED', 'DEPRECATED', 'RETIRED');
-- Create enum type "vendor_endpoint_type_enum"
CREATE TYPE "integration"."vendor_endpoint_type_enum" AS ENUM ('SESSION_LOOKUP', 'TARIFF_QUERY', 'PAYMENT_CREATE', 'PAYMENT_STATUS', 'WEBHOOK_RECEIVE', 'GATE_COMMAND', 'HEALTH_CHECK', 'TOKEN_REQUEST', 'EVIDENCE_UPLOAD', 'OTHER');
-- Create enum type "vendor_system_status_enum"
CREATE TYPE "integration"."vendor_system_status_enum" AS ENUM ('DRAFT', 'ACTIVE', 'MAINTENANCE', 'SUSPENDED', 'DEPRECATED', 'RETIRED');
-- Create enum type "vendor_system_type_enum"
CREATE TYPE "integration"."vendor_system_type_enum" AS ENUM ('VENDOR_PMS', 'PAYMENT_PROVIDER', 'GATE_CONTROLLER', 'LPR_PROVIDER', 'MOPS_PROVIDER', 'EVIDENCE_STORAGE', 'NOTIFICATION_PROVIDER', 'OTHER');
-- Create "adapter_mappings" table
CREATE TABLE "integration"."adapter_mappings" (
  "adapter_mapping_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "vendor_system_id" uuid NOT NULL,
  "mapping_type" "integration"."adapter_mapping_type_enum" NOT NULL,
  "site_group_id" uuid NULL,
  "site_id" uuid NULL,
  "lane_id" uuid NULL,
  "gate_device_id" uuid NULL,
  "payment_rail_id" uuid NULL,
  "vendor_object_type" character varying(64) NOT NULL,
  "vendor_object_ref" character varying(128) NOT NULL,
  "vendor_object_name" character varying(128) NULL,
  "mapping_status" "integration"."adapter_mapping_status_enum" NOT NULL,
  "mapping_confidence" "integration"."adapter_mapping_confidence_enum" NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_adapter_mappings" PRIMARY KEY ("adapter_mapping_id")
);
-- Create index "ix_adapter_mappings__gate_device_id" to table: "adapter_mappings"
CREATE INDEX "ix_adapter_mappings__gate_device_id" ON "integration"."adapter_mappings" ("gate_device_id");
-- Create index "ix_adapter_mappings__lane_id" to table: "adapter_mappings"
CREATE INDEX "ix_adapter_mappings__lane_id" ON "integration"."adapter_mappings" ("lane_id");
-- Create index "ix_adapter_mappings__site_group_id" to table: "adapter_mappings"
CREATE INDEX "ix_adapter_mappings__site_group_id" ON "integration"."adapter_mappings" ("site_group_id");
-- Create index "ix_adapter_mappings__site_id" to table: "adapter_mappings"
CREATE INDEX "ix_adapter_mappings__site_id" ON "integration"."adapter_mappings" ("site_id");
-- Create index "ix_adapter_mappings__vendor_system_id" to table: "adapter_mappings"
CREATE INDEX "ix_adapter_mappings__vendor_system_id" ON "integration"."adapter_mappings" ("vendor_system_id");
-- Create index "ux_adapter_mappings__vendor_object_active" to table: "adapter_mappings"
CREATE UNIQUE INDEX "ux_adapter_mappings__vendor_object_active" ON "integration"."adapter_mappings" ("vendor_system_id", "mapping_type", "vendor_object_type", "vendor_object_ref") WHERE (mapping_status = 'ACTIVE'::integration.adapter_mapping_status_enum);
-- Set comment to table: "adapter_mappings"
COMMENT ON TABLE "integration"."adapter_mappings" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "adapter_mapping_id" on table: "adapter_mappings"
COMMENT ON COLUMN "integration"."adapter_mappings"."adapter_mapping_id" IS 'Canonical identifier of the adapter mapping.';
-- Set comment to column: "vendor_system_id" on table: "adapter_mappings"
COMMENT ON COLUMN "integration"."adapter_mappings"."vendor_system_id" IS 'Vendor system to which the mapping applies.';
-- Set comment to column: "mapping_type" on table: "adapter_mappings"
COMMENT ON COLUMN "integration"."adapter_mappings"."mapping_type" IS 'Type of mapping.';
-- Set comment to column: "site_group_id" on table: "adapter_mappings"
COMMENT ON COLUMN "integration"."adapter_mappings"."site_group_id" IS 'ExitPass site group being mapped.';
-- Set comment to column: "site_id" on table: "adapter_mappings"
COMMENT ON COLUMN "integration"."adapter_mappings"."site_id" IS 'ExitPass site being mapped.';
-- Set comment to column: "lane_id" on table: "adapter_mappings"
COMMENT ON COLUMN "integration"."adapter_mappings"."lane_id" IS 'ExitPass lane being mapped.';
-- Set comment to column: "gate_device_id" on table: "adapter_mappings"
COMMENT ON COLUMN "integration"."adapter_mappings"."gate_device_id" IS 'ExitPass gate device being mapped.';
-- Set comment to column: "payment_rail_id" on table: "adapter_mappings"
COMMENT ON COLUMN "integration"."adapter_mappings"."payment_rail_id" IS 'ExitPass payment rail being mapped.';
-- Set comment to column: "vendor_object_type" on table: "adapter_mappings"
COMMENT ON COLUMN "integration"."adapter_mappings"."vendor_object_type" IS 'Vendor object type.';
-- Set comment to column: "vendor_object_ref" on table: "adapter_mappings"
COMMENT ON COLUMN "integration"."adapter_mappings"."vendor_object_ref" IS 'Vendor object identifier.';
-- Set comment to column: "vendor_object_name" on table: "adapter_mappings"
COMMENT ON COLUMN "integration"."adapter_mappings"."vendor_object_name" IS 'Vendor object display name.';
-- Set comment to column: "mapping_status" on table: "adapter_mappings"
COMMENT ON COLUMN "integration"."adapter_mappings"."mapping_status" IS 'Mapping lifecycle status.';
-- Set comment to column: "mapping_confidence" on table: "adapter_mappings"
COMMENT ON COLUMN "integration"."adapter_mappings"."mapping_confidence" IS 'Confidence or source of mapping.';
-- Set comment to column: "effective_from" on table: "adapter_mappings"
COMMENT ON COLUMN "integration"."adapter_mappings"."effective_from" IS 'Start of mapping effectiveness.';
-- Set comment to column: "effective_to" on table: "adapter_mappings"
COMMENT ON COLUMN "integration"."adapter_mappings"."effective_to" IS 'End of mapping effectiveness.';
-- Set comment to column: "created_at" on table: "adapter_mappings"
COMMENT ON COLUMN "integration"."adapter_mappings"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "adapter_mappings"
COMMENT ON COLUMN "integration"."adapter_mappings"."created_by_user_id" IS 'User who created the mapping.';
-- Set comment to column: "created_by_service_identity_id" on table: "adapter_mappings"
COMMENT ON COLUMN "integration"."adapter_mappings"."created_by_service_identity_id" IS 'Service identity that created the mapping.';
-- Set comment to column: "updated_at" on table: "adapter_mappings"
COMMENT ON COLUMN "integration"."adapter_mappings"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "adapter_mappings"
COMMENT ON COLUMN "integration"."adapter_mappings"."updated_by_user_id" IS 'User who last updated the mapping.';
-- Set comment to column: "updated_by_service_identity_id" on table: "adapter_mappings"
COMMENT ON COLUMN "integration"."adapter_mappings"."updated_by_service_identity_id" IS 'Service identity that last updated the mapping.';
-- Set comment to column: "row_version" on table: "adapter_mappings"
COMMENT ON COLUMN "integration"."adapter_mappings"."row_version" IS 'Optimistic concurrency version.';
-- Create "integration_credential_references" table
CREATE TABLE "integration"."integration_credential_references" (
  "integration_credential_reference_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "vendor_system_id" uuid NOT NULL,
  "service_identity_id" uuid NULL,
  "credential_code" character varying(64) NOT NULL,
  "credential_name" character varying(128) NOT NULL,
  "credential_type" "integration"."integration_credential_type_enum" NOT NULL,
  "secret_store_type" "integration"."secret_store_type_enum" NOT NULL,
  "secret_reference" character varying(256) NOT NULL,
  "credential_status" "integration"."integration_credential_status_enum" NOT NULL,
  "credential_version_ref" character varying(128) NULL,
  "last_rotated_at" timestamptz NULL,
  "next_rotation_due_at" timestamptz NULL,
  "expires_at" timestamptz NULL,
  "revoked_at" timestamptz NULL,
  "revocation_reason_code" character varying(64) NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_integration_credential_references" PRIMARY KEY ("integration_credential_reference_id")
);
-- Create index "ix_integration_credential_references__credential_status" to table: "integration_credential_references"
CREATE INDEX "ix_integration_credential_references__credential_status" ON "integration"."integration_credential_references" ("credential_status");
-- Create index "ix_integration_credential_references__last_rotated_at" to table: "integration_credential_references"
CREATE INDEX "ix_integration_credential_references__last_rotated_at" ON "integration"."integration_credential_references" ("last_rotated_at");
-- Create index "ix_integration_credential_references__next_rotation_due_at" to table: "integration_credential_references"
CREATE INDEX "ix_integration_credential_references__next_rotation_due_at" ON "integration"."integration_credential_references" ("next_rotation_due_at");
-- Create index "ix_integration_credential_references__service_identity_id" to table: "integration_credential_references"
CREATE INDEX "ix_integration_credential_references__service_identity_id" ON "integration"."integration_credential_references" ("service_identity_id");
-- Create index "ix_integration_credential_references__vendor_system_id" to table: "integration_credential_references"
CREATE INDEX "ix_integration_credential_references__vendor_system_id" ON "integration"."integration_credential_references" ("vendor_system_id");
-- Set comment to table: "integration_credential_references"
COMMENT ON TABLE "integration"."integration_credential_references" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "integration_credential_reference_id" on table: "integration_credential_references"
COMMENT ON COLUMN "integration"."integration_credential_references"."integration_credential_reference_id" IS 'Canonical identifier of the credential reference.';
-- Set comment to column: "vendor_system_id" on table: "integration_credential_references"
COMMENT ON COLUMN "integration"."integration_credential_references"."vendor_system_id" IS 'Vendor system using the credential.';
-- Set comment to column: "service_identity_id" on table: "integration_credential_references"
COMMENT ON COLUMN "integration"."integration_credential_references"."service_identity_id" IS 'Service identity associated with the credential.';
-- Set comment to column: "credential_code" on table: "integration_credential_references"
COMMENT ON COLUMN "integration"."integration_credential_references"."credential_code" IS 'Stable credential reference code.';
-- Set comment to column: "credential_name" on table: "integration_credential_references"
COMMENT ON COLUMN "integration"."integration_credential_references"."credential_name" IS 'Human-readable credential reference name.';
-- Set comment to column: "credential_type" on table: "integration_credential_references"
COMMENT ON COLUMN "integration"."integration_credential_references"."credential_type" IS 'Credential type.';
-- Set comment to column: "secret_store_type" on table: "integration_credential_references"
COMMENT ON COLUMN "integration"."integration_credential_references"."secret_store_type" IS 'Secret store type.';
-- Set comment to column: "secret_reference" on table: "integration_credential_references"
COMMENT ON COLUMN "integration"."integration_credential_references"."secret_reference" IS 'Vault/key-store reference to secret material.';
-- Set comment to column: "credential_status" on table: "integration_credential_references"
COMMENT ON COLUMN "integration"."integration_credential_references"."credential_status" IS 'Credential reference lifecycle status.';
-- Set comment to column: "credential_version_ref" on table: "integration_credential_references"
COMMENT ON COLUMN "integration"."integration_credential_references"."credential_version_ref" IS 'Secret version or certificate version reference.';
-- Set comment to column: "last_rotated_at" on table: "integration_credential_references"
COMMENT ON COLUMN "integration"."integration_credential_references"."last_rotated_at" IS 'Last rotation timestamp.';
-- Set comment to column: "next_rotation_due_at" on table: "integration_credential_references"
COMMENT ON COLUMN "integration"."integration_credential_references"."next_rotation_due_at" IS 'Next required rotation timestamp.';
-- Set comment to column: "expires_at" on table: "integration_credential_references"
COMMENT ON COLUMN "integration"."integration_credential_references"."expires_at" IS 'Credential expiry timestamp.';
-- Set comment to column: "revoked_at" on table: "integration_credential_references"
COMMENT ON COLUMN "integration"."integration_credential_references"."revoked_at" IS 'Credential revocation timestamp.';
-- Set comment to column: "revocation_reason_code" on table: "integration_credential_references"
COMMENT ON COLUMN "integration"."integration_credential_references"."revocation_reason_code" IS 'Controlled revocation reason.';
-- Set comment to column: "created_at" on table: "integration_credential_references"
COMMENT ON COLUMN "integration"."integration_credential_references"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "integration_credential_references"
COMMENT ON COLUMN "integration"."integration_credential_references"."created_by_user_id" IS 'User who created the credential reference.';
-- Set comment to column: "created_by_service_identity_id" on table: "integration_credential_references"
COMMENT ON COLUMN "integration"."integration_credential_references"."created_by_service_identity_id" IS 'Service identity that created the credential reference.';
-- Set comment to column: "updated_at" on table: "integration_credential_references"
COMMENT ON COLUMN "integration"."integration_credential_references"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "integration_credential_references"
COMMENT ON COLUMN "integration"."integration_credential_references"."updated_by_user_id" IS 'User who last updated the credential reference.';
-- Set comment to column: "updated_by_service_identity_id" on table: "integration_credential_references"
COMMENT ON COLUMN "integration"."integration_credential_references"."updated_by_service_identity_id" IS 'Service identity that last updated the credential reference.';
-- Set comment to column: "row_version" on table: "integration_credential_references"
COMMENT ON COLUMN "integration"."integration_credential_references"."row_version" IS 'Optimistic concurrency version.';
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
);
-- Create index "ix_integration_health_records__correlation_id" to table: "integration_health_records"
CREATE INDEX "ix_integration_health_records__correlation_id" ON "integration"."integration_health_records" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_integration_health_records__site_group_id" to table: "integration_health_records"
CREATE INDEX "ix_integration_health_records__site_group_id" ON "integration"."integration_health_records" ("site_group_id");
-- Create index "ix_integration_health_records__site_id" to table: "integration_health_records"
CREATE INDEX "ix_integration_health_records__site_id" ON "integration"."integration_health_records" ("site_id");
-- Create index "ix_integration_health_records__vendor_endpoint_id" to table: "integration_health_records"
CREATE INDEX "ix_integration_health_records__vendor_endpoint_id" ON "integration"."integration_health_records" ("vendor_endpoint_id");
-- Create index "ix_integration_health_records__vendor_system_id" to table: "integration_health_records"
CREATE INDEX "ix_integration_health_records__vendor_system_id" ON "integration"."integration_health_records" ("vendor_system_id");
-- Set comment to table: "integration_health_records"
COMMENT ON TABLE "integration"."integration_health_records" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "integration_health_record_id" on table: "integration_health_records"
COMMENT ON COLUMN "integration"."integration_health_records"."integration_health_record_id" IS 'Canonical identifier of the health record.';
-- Set comment to column: "vendor_system_id" on table: "integration_health_records"
COMMENT ON COLUMN "integration"."integration_health_records"."vendor_system_id" IS 'Vendor system being observed.';
-- Set comment to column: "vendor_endpoint_id" on table: "integration_health_records"
COMMENT ON COLUMN "integration"."integration_health_records"."vendor_endpoint_id" IS 'Endpoint being observed, where endpoint-specific.';
-- Set comment to column: "site_group_id" on table: "integration_health_records"
COMMENT ON COLUMN "integration"."integration_health_records"."site_group_id" IS 'Site group affected, where applicable.';
-- Set comment to column: "site_id" on table: "integration_health_records"
COMMENT ON COLUMN "integration"."integration_health_records"."site_id" IS 'Site affected, where applicable.';
-- Set comment to column: "incident_record_id" on table: "integration_health_records"
COMMENT ON COLUMN "integration"."integration_health_records"."incident_record_id" IS 'Related incident, where material.';
-- Set comment to column: "health_status" on table: "integration_health_records"
COMMENT ON COLUMN "integration"."integration_health_records"."health_status" IS 'Health status.';
-- Set comment to column: "health_check_type" on table: "integration_health_records"
COMMENT ON COLUMN "integration"."integration_health_records"."health_check_type" IS 'Health check type.';
-- Set comment to column: "http_status_code" on table: "integration_health_records"
COMMENT ON COLUMN "integration"."integration_health_records"."http_status_code" IS 'HTTP status code where applicable.';
-- Set comment to column: "latency_ms" on table: "integration_health_records"
COMMENT ON COLUMN "integration"."integration_health_records"."latency_ms" IS 'Observed latency in milliseconds.';
-- Set comment to column: "failure_reason_code" on table: "integration_health_records"
COMMENT ON COLUMN "integration"."integration_health_records"."failure_reason_code" IS 'Controlled failure or degradation reason.';
-- Set comment to column: "error_code" on table: "integration_health_records"
COMMENT ON COLUMN "integration"."integration_health_records"."error_code" IS 'Vendor or adapter error code.';
-- Set comment to column: "error_detail_ref" on table: "integration_health_records"
COMMENT ON COLUMN "integration"."integration_health_records"."error_detail_ref" IS 'Reference to detailed diagnostic payload if retained.';
-- Set comment to column: "observed_at" on table: "integration_health_records"
COMMENT ON COLUMN "integration"."integration_health_records"."observed_at" IS 'Timestamp when health was observed.';
-- Set comment to column: "recovered_at" on table: "integration_health_records"
COMMENT ON COLUMN "integration"."integration_health_records"."recovered_at" IS 'Recovery timestamp, where recorded in this health record.';
-- Set comment to column: "observed_by_service_identity_id" on table: "integration_health_records"
COMMENT ON COLUMN "integration"."integration_health_records"."observed_by_service_identity_id" IS 'Service identity that observed or recorded health.';
-- Set comment to column: "correlation_id" on table: "integration_health_records"
COMMENT ON COLUMN "integration"."integration_health_records"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "integration_health_records"
COMMENT ON COLUMN "integration"."integration_health_records"."created_at" IS 'Record creation timestamp.';
-- Create "vendor_endpoints" table
CREATE TABLE "integration"."vendor_endpoints" (
  "vendor_endpoint_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "vendor_system_id" uuid NOT NULL,
  "endpoint_code" character varying(96) NOT NULL,
  "endpoint_name" character varying(128) NOT NULL,
  "endpoint_description" text NULL,
  "endpoint_type" "integration"."vendor_endpoint_type_enum" NOT NULL,
  "http_method" "integration"."http_method_enum" NULL,
  "path_template" character varying(512) NULL,
  "operation_ref" character varying(128) NULL,
  "credential_reference_id" uuid NULL,
  "timeout_policy_code" character varying(64) NULL,
  "retry_policy_code" character varying(64) NULL,
  "rate_limit_policy_code" character varying(64) NULL,
  "endpoint_status" "integration"."vendor_endpoint_status_enum" NOT NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_vendor_endpoints" PRIMARY KEY ("vendor_endpoint_id"),
  CONSTRAINT "uq_vendor_endpoints__vendor_endpoint_code" UNIQUE ("vendor_system_id", "endpoint_code")
);
-- Create index "ix_vendor_endpoints__credential_reference_id" to table: "vendor_endpoints"
CREATE INDEX "ix_vendor_endpoints__credential_reference_id" ON "integration"."vendor_endpoints" ("credential_reference_id");
-- Create index "ix_vendor_endpoints__endpoint_status" to table: "vendor_endpoints"
CREATE INDEX "ix_vendor_endpoints__endpoint_status" ON "integration"."vendor_endpoints" ("endpoint_status");
-- Create index "ix_vendor_endpoints__vendor_system_id" to table: "vendor_endpoints"
CREATE INDEX "ix_vendor_endpoints__vendor_system_id" ON "integration"."vendor_endpoints" ("vendor_system_id");
-- Set comment to table: "vendor_endpoints"
COMMENT ON TABLE "integration"."vendor_endpoints" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "vendor_endpoint_id" on table: "vendor_endpoints"
COMMENT ON COLUMN "integration"."vendor_endpoints"."vendor_endpoint_id" IS 'Canonical identifier of the vendor endpoint.';
-- Set comment to column: "vendor_system_id" on table: "vendor_endpoints"
COMMENT ON COLUMN "integration"."vendor_endpoints"."vendor_system_id" IS 'Vendor system that exposes the endpoint.';
-- Set comment to column: "endpoint_code" on table: "vendor_endpoints"
COMMENT ON COLUMN "integration"."vendor_endpoints"."endpoint_code" IS 'Stable internal endpoint operation code.';
-- Set comment to column: "endpoint_name" on table: "vendor_endpoints"
COMMENT ON COLUMN "integration"."vendor_endpoints"."endpoint_name" IS 'Human-readable endpoint name.';
-- Set comment to column: "endpoint_description" on table: "vendor_endpoints"
COMMENT ON COLUMN "integration"."vendor_endpoints"."endpoint_description" IS 'Endpoint description.';
-- Set comment to column: "endpoint_type" on table: "vendor_endpoints"
COMMENT ON COLUMN "integration"."vendor_endpoints"."endpoint_type" IS 'Endpoint classification.';
-- Set comment to column: "http_method" on table: "vendor_endpoints"
COMMENT ON COLUMN "integration"."vendor_endpoints"."http_method" IS 'HTTP method where REST-based.';
-- Set comment to column: "path_template" on table: "vendor_endpoints"
COMMENT ON COLUMN "integration"."vendor_endpoints"."path_template" IS 'Endpoint path template.';
-- Set comment to column: "operation_ref" on table: "vendor_endpoints"
COMMENT ON COLUMN "integration"."vendor_endpoints"."operation_ref" IS 'Vendor SDK, SOAP, OpenAPI, or operation reference.';
-- Set comment to column: "credential_reference_id" on table: "vendor_endpoints"
COMMENT ON COLUMN "integration"."vendor_endpoints"."credential_reference_id" IS 'Credential reference used by the endpoint.';
-- Set comment to column: "timeout_policy_code" on table: "vendor_endpoints"
COMMENT ON COLUMN "integration"."vendor_endpoints"."timeout_policy_code" IS 'Timeout policy code.';
-- Set comment to column: "retry_policy_code" on table: "vendor_endpoints"
COMMENT ON COLUMN "integration"."vendor_endpoints"."retry_policy_code" IS 'Retry policy code.';
-- Set comment to column: "rate_limit_policy_code" on table: "vendor_endpoints"
COMMENT ON COLUMN "integration"."vendor_endpoints"."rate_limit_policy_code" IS 'Rate-limit policy code.';
-- Set comment to column: "endpoint_status" on table: "vendor_endpoints"
COMMENT ON COLUMN "integration"."vendor_endpoints"."endpoint_status" IS 'Endpoint lifecycle status.';
-- Set comment to column: "effective_from" on table: "vendor_endpoints"
COMMENT ON COLUMN "integration"."vendor_endpoints"."effective_from" IS 'Start of endpoint effectiveness.';
-- Set comment to column: "effective_to" on table: "vendor_endpoints"
COMMENT ON COLUMN "integration"."vendor_endpoints"."effective_to" IS 'End of endpoint effectiveness.';
-- Set comment to column: "created_at" on table: "vendor_endpoints"
COMMENT ON COLUMN "integration"."vendor_endpoints"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "vendor_endpoints"
COMMENT ON COLUMN "integration"."vendor_endpoints"."created_by_user_id" IS 'User who created the endpoint.';
-- Set comment to column: "created_by_service_identity_id" on table: "vendor_endpoints"
COMMENT ON COLUMN "integration"."vendor_endpoints"."created_by_service_identity_id" IS 'Service identity that created the endpoint.';
-- Set comment to column: "updated_at" on table: "vendor_endpoints"
COMMENT ON COLUMN "integration"."vendor_endpoints"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "vendor_endpoints"
COMMENT ON COLUMN "integration"."vendor_endpoints"."updated_by_user_id" IS 'User who last updated the endpoint.';
-- Set comment to column: "updated_by_service_identity_id" on table: "vendor_endpoints"
COMMENT ON COLUMN "integration"."vendor_endpoints"."updated_by_service_identity_id" IS 'Service identity that last updated the endpoint.';
-- Set comment to column: "row_version" on table: "vendor_endpoints"
COMMENT ON COLUMN "integration"."vendor_endpoints"."row_version" IS 'Optimistic concurrency version.';
-- Create "vendor_systems" table
CREATE TABLE "integration"."vendor_systems" (
  "vendor_system_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "vendor_code" character varying(64) NOT NULL,
  "vendor_name" character varying(128) NOT NULL,
  "vendor_system_type" "integration"."vendor_system_type_enum" NOT NULL,
  "vendor_system_status" "integration"."vendor_system_status_enum" NOT NULL,
  "environment_code" character varying(32) NOT NULL,
  "base_url_ref" character varying(256) NULL,
  "api_version" character varying(64) NULL,
  "owner_team" character varying(128) NULL,
  "support_contact_ref" character varying(128) NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_vendor_systems" PRIMARY KEY ("vendor_system_id"),
  CONSTRAINT "uq_vendor_systems__vendor_code_environment" UNIQUE ("vendor_code", "environment_code")
);
-- Create index "ix_vendor_systems__vendor_system_status" to table: "vendor_systems"
CREATE INDEX "ix_vendor_systems__vendor_system_status" ON "integration"."vendor_systems" ("vendor_system_status");
-- Set comment to table: "vendor_systems"
COMMENT ON TABLE "integration"."vendor_systems" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "vendor_system_id" on table: "vendor_systems"
COMMENT ON COLUMN "integration"."vendor_systems"."vendor_system_id" IS 'Canonical identifier of the vendor system.';
-- Set comment to column: "vendor_code" on table: "vendor_systems"
COMMENT ON COLUMN "integration"."vendor_systems"."vendor_code" IS 'Stable internal vendor code.';
-- Set comment to column: "vendor_name" on table: "vendor_systems"
COMMENT ON COLUMN "integration"."vendor_systems"."vendor_name" IS 'Human-readable vendor or system name.';
-- Set comment to column: "vendor_system_type" on table: "vendor_systems"
COMMENT ON COLUMN "integration"."vendor_systems"."vendor_system_type" IS 'Vendor system classification.';
-- Set comment to column: "vendor_system_status" on table: "vendor_systems"
COMMENT ON COLUMN "integration"."vendor_systems"."vendor_system_status" IS 'Vendor system lifecycle status.';
-- Set comment to column: "environment_code" on table: "vendor_systems"
COMMENT ON COLUMN "integration"."vendor_systems"."environment_code" IS 'Environment where vendor profile applies.';
-- Set comment to column: "base_url_ref" on table: "vendor_systems"
COMMENT ON COLUMN "integration"."vendor_systems"."base_url_ref" IS 'Reference or non-secret base URL configuration.';
-- Set comment to column: "api_version" on table: "vendor_systems"
COMMENT ON COLUMN "integration"."vendor_systems"."api_version" IS 'Vendor API version used.';
-- Set comment to column: "owner_team" on table: "vendor_systems"
COMMENT ON COLUMN "integration"."vendor_systems"."owner_team" IS 'Internal owner team or responsible unit.';
-- Set comment to column: "support_contact_ref" on table: "vendor_systems"
COMMENT ON COLUMN "integration"."vendor_systems"."support_contact_ref" IS 'Support contact or vendor support reference.';
-- Set comment to column: "effective_from" on table: "vendor_systems"
COMMENT ON COLUMN "integration"."vendor_systems"."effective_from" IS 'Start of vendor system effectiveness.';
-- Set comment to column: "effective_to" on table: "vendor_systems"
COMMENT ON COLUMN "integration"."vendor_systems"."effective_to" IS 'End of vendor system effectiveness.';
-- Set comment to column: "created_at" on table: "vendor_systems"
COMMENT ON COLUMN "integration"."vendor_systems"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "vendor_systems"
COMMENT ON COLUMN "integration"."vendor_systems"."created_by_user_id" IS 'User who created the vendor system record.';
-- Set comment to column: "created_by_service_identity_id" on table: "vendor_systems"
COMMENT ON COLUMN "integration"."vendor_systems"."created_by_service_identity_id" IS 'Service identity that created the vendor system record.';
-- Set comment to column: "updated_at" on table: "vendor_systems"
COMMENT ON COLUMN "integration"."vendor_systems"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "vendor_systems"
COMMENT ON COLUMN "integration"."vendor_systems"."updated_by_user_id" IS 'User who last updated the vendor system record.';
-- Set comment to column: "updated_by_service_identity_id" on table: "vendor_systems"
COMMENT ON COLUMN "integration"."vendor_systems"."updated_by_service_identity_id" IS 'Service identity that last updated the vendor system record.';
-- Set comment to column: "row_version" on table: "vendor_systems"
COMMENT ON COLUMN "integration"."vendor_systems"."row_version" IS 'Optimistic concurrency version.';
-- Create enum type "merchant_scope_type_enum"
CREATE TYPE "merchants"."merchant_scope_type_enum" AS ENUM ('SITE_GROUP', 'SITE');
-- Create enum type "merchant_site_scope_status_enum"
CREATE TYPE "merchants"."merchant_site_scope_status_enum" AS ENUM ('DRAFT', 'ACTIVE', 'SUSPENDED', 'EXPIRED', 'REVOKED', 'RETIRED');
-- Create enum type "merchant_status_enum"
CREATE TYPE "merchants"."merchant_status_enum" AS ENUM ('DRAFT', 'ACTIVE', 'SUSPENDED', 'INACTIVE', 'RETIRED');
-- Create enum type "merchant_type_enum"
CREATE TYPE "merchants"."merchant_type_enum" AS ENUM ('TENANT', 'ANCHOR_TENANT', 'PROPERTY_OPERATOR', 'INSTITUTION', 'SERVICE_PROVIDER', 'PROMOTIONAL_PARTNER', 'OTHER');
-- Create enum type "merchant_user_status_enum"
CREATE TYPE "merchants"."merchant_user_status_enum" AS ENUM ('INVITED', 'ACTIVE', 'SUSPENDED', 'REVOKED', 'EXPIRED', 'RETIRED');
-- Create enum type "merchant_user_type_enum"
CREATE TYPE "merchants"."merchant_user_type_enum" AS ENUM ('MERCHANT_ADMIN', 'MERCHANT_MANAGER', 'MERCHANT_STAFF', 'REPORT_VIEWER', 'COUPON_OPERATOR', 'OTHER');
-- Create enum type "merchant_wallet_status_enum"
CREATE TYPE "merchants"."merchant_wallet_status_enum" AS ENUM ('DRAFT', 'ACTIVE', 'SUSPENDED', 'FROZEN', 'CLOSED', 'RETIRED');
-- Create enum type "merchant_wallet_type_enum"
CREATE TYPE "merchants"."merchant_wallet_type_enum" AS ENUM ('PRE_FUNDED', 'POSTPAID_SPONSORSHIP', 'CREDIT_LIMIT', 'EXTERNAL_LEDGER', 'PROMOTIONAL_BUDGET', 'OTHER');
-- Create "merchant_site_scopes" table
CREATE TABLE "merchants"."merchant_site_scopes" (
  "merchant_site_scope_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "merchant_id" uuid NOT NULL,
  "site_group_id" uuid NULL,
  "site_id" uuid NULL,
  "scope_type" "merchants"."merchant_scope_type_enum" NOT NULL,
  "scope_status" "merchants"."merchant_site_scope_status_enum" NOT NULL,
  "scope_reason_code" character varying(64) NULL,
  "allows_coupon_sponsorship" boolean NOT NULL DEFAULT false,
  "allows_full_waiver" boolean NOT NULL DEFAULT false,
  "requires_elevated_approval" boolean NOT NULL DEFAULT false,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "approved_at" timestamptz NULL,
  "approved_by_user_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_merchant_site_scopes" PRIMARY KEY ("merchant_site_scope_id")
);
-- Create index "ix_merchant_site_scopes__merchant_id" to table: "merchant_site_scopes"
CREATE INDEX "ix_merchant_site_scopes__merchant_id" ON "merchants"."merchant_site_scopes" ("merchant_id");
-- Create index "ix_merchant_site_scopes__site_group_id" to table: "merchant_site_scopes"
CREATE INDEX "ix_merchant_site_scopes__site_group_id" ON "merchants"."merchant_site_scopes" ("site_group_id");
-- Create index "ix_merchant_site_scopes__site_id" to table: "merchant_site_scopes"
CREATE INDEX "ix_merchant_site_scopes__site_id" ON "merchants"."merchant_site_scopes" ("site_id");
-- Create index "ux_merchant_site_scopes__active_site_group_scope" to table: "merchant_site_scopes"
CREATE UNIQUE INDEX "ux_merchant_site_scopes__active_site_group_scope" ON "merchants"."merchant_site_scopes" ("merchant_id", "site_group_id", "scope_type") WHERE ((scope_status = 'ACTIVE'::merchants.merchant_site_scope_status_enum) AND (site_group_id IS NOT NULL) AND (site_id IS NULL));
-- Create index "ux_merchant_site_scopes__active_site_scope" to table: "merchant_site_scopes"
CREATE UNIQUE INDEX "ux_merchant_site_scopes__active_site_scope" ON "merchants"."merchant_site_scopes" ("merchant_id", "site_id", "scope_type") WHERE ((scope_status = 'ACTIVE'::merchants.merchant_site_scope_status_enum) AND (site_id IS NOT NULL));
-- Set comment to table: "merchant_site_scopes"
COMMENT ON TABLE "merchants"."merchant_site_scopes" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "merchant_site_scope_id" on table: "merchant_site_scopes"
COMMENT ON COLUMN "merchants"."merchant_site_scopes"."merchant_site_scope_id" IS 'Canonical identifier of the merchant site scope.';
-- Set comment to column: "merchant_id" on table: "merchant_site_scopes"
COMMENT ON COLUMN "merchants"."merchant_site_scopes"."merchant_id" IS 'Merchant to which the scope belongs.';
-- Set comment to column: "site_group_id" on table: "merchant_site_scopes"
COMMENT ON COLUMN "merchants"."merchant_site_scopes"."site_group_id" IS 'Site group scope.';
-- Set comment to column: "site_id" on table: "merchant_site_scopes"
COMMENT ON COLUMN "merchants"."merchant_site_scopes"."site_id" IS 'Site scope.';
-- Set comment to column: "scope_type" on table: "merchant_site_scopes"
COMMENT ON COLUMN "merchants"."merchant_site_scopes"."scope_type" IS 'Scope level.';
-- Set comment to column: "scope_status" on table: "merchant_site_scopes"
COMMENT ON COLUMN "merchants"."merchant_site_scopes"."scope_status" IS 'Scope lifecycle status.';
-- Set comment to column: "scope_reason_code" on table: "merchant_site_scopes"
COMMENT ON COLUMN "merchants"."merchant_site_scopes"."scope_reason_code" IS 'Controlled reason for granting or changing scope.';
-- Set comment to column: "allows_coupon_sponsorship" on table: "merchant_site_scopes"
COMMENT ON COLUMN "merchants"."merchant_site_scopes"."allows_coupon_sponsorship" IS 'Indicates whether merchant may sponsor coupons in this scope.';
-- Set comment to column: "allows_full_waiver" on table: "merchant_site_scopes"
COMMENT ON COLUMN "merchants"."merchant_site_scopes"."allows_full_waiver" IS 'Indicates whether full-waiver coupons may be used in this scope.';
-- Set comment to column: "requires_elevated_approval" on table: "merchant_site_scopes"
COMMENT ON COLUMN "merchants"."merchant_site_scopes"."requires_elevated_approval" IS 'Indicates whether merchant actions in this scope require elevated approval.';
-- Set comment to column: "effective_from" on table: "merchant_site_scopes"
COMMENT ON COLUMN "merchants"."merchant_site_scopes"."effective_from" IS 'Start of scope effectiveness.';
-- Set comment to column: "effective_to" on table: "merchant_site_scopes"
COMMENT ON COLUMN "merchants"."merchant_site_scopes"."effective_to" IS 'End of scope effectiveness.';
-- Set comment to column: "approved_at" on table: "merchant_site_scopes"
COMMENT ON COLUMN "merchants"."merchant_site_scopes"."approved_at" IS 'Timestamp when scope was approved.';
-- Set comment to column: "approved_by_user_id" on table: "merchant_site_scopes"
COMMENT ON COLUMN "merchants"."merchant_site_scopes"."approved_by_user_id" IS 'User who approved the scope.';
-- Set comment to column: "created_at" on table: "merchant_site_scopes"
COMMENT ON COLUMN "merchants"."merchant_site_scopes"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "merchant_site_scopes"
COMMENT ON COLUMN "merchants"."merchant_site_scopes"."created_by_user_id" IS 'User who created the scope.';
-- Set comment to column: "created_by_service_identity_id" on table: "merchant_site_scopes"
COMMENT ON COLUMN "merchants"."merchant_site_scopes"."created_by_service_identity_id" IS 'Service identity that created the scope.';
-- Set comment to column: "updated_at" on table: "merchant_site_scopes"
COMMENT ON COLUMN "merchants"."merchant_site_scopes"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "merchant_site_scopes"
COMMENT ON COLUMN "merchants"."merchant_site_scopes"."updated_by_user_id" IS 'User who last updated the scope.';
-- Set comment to column: "updated_by_service_identity_id" on table: "merchant_site_scopes"
COMMENT ON COLUMN "merchants"."merchant_site_scopes"."updated_by_service_identity_id" IS 'Service identity that last updated the scope.';
-- Set comment to column: "row_version" on table: "merchant_site_scopes"
COMMENT ON COLUMN "merchants"."merchant_site_scopes"."row_version" IS 'Optimistic concurrency version.';
-- Create "merchant_users" table
CREATE TABLE "merchants"."merchant_users" (
  "merchant_user_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "merchant_id" uuid NOT NULL,
  "user_id" uuid NOT NULL,
  "merchant_user_status" "merchants"."merchant_user_status_enum" NOT NULL,
  "merchant_user_type" "merchants"."merchant_user_type_enum" NOT NULL,
  "can_request_coupon" boolean NOT NULL DEFAULT false,
  "can_manage_coupon" boolean NOT NULL DEFAULT false,
  "can_view_wallet" boolean NOT NULL DEFAULT false,
  "can_view_reports" boolean NOT NULL DEFAULT false,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "invited_at" timestamptz NULL,
  "accepted_at" timestamptz NULL,
  "revoked_at" timestamptz NULL,
  "revoked_by_user_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_merchant_users" PRIMARY KEY ("merchant_user_id")
);
-- Create index "ix_merchant_users__merchant_id" to table: "merchant_users"
CREATE INDEX "ix_merchant_users__merchant_id" ON "merchants"."merchant_users" ("merchant_id");
-- Create index "ix_merchant_users__merchant_user_status" to table: "merchant_users"
CREATE INDEX "ix_merchant_users__merchant_user_status" ON "merchants"."merchant_users" ("merchant_user_status");
-- Create index "ix_merchant_users__user_id" to table: "merchant_users"
CREATE INDEX "ix_merchant_users__user_id" ON "merchants"."merchant_users" ("user_id");
-- Create index "ux_merchant_users__active_user_merchant" to table: "merchant_users"
CREATE UNIQUE INDEX "ux_merchant_users__active_user_merchant" ON "merchants"."merchant_users" ("merchant_id", "user_id") WHERE (merchant_user_status = 'ACTIVE'::merchants.merchant_user_status_enum);
-- Set comment to table: "merchant_users"
COMMENT ON TABLE "merchants"."merchant_users" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "merchant_user_id" on table: "merchant_users"
COMMENT ON COLUMN "merchants"."merchant_users"."merchant_user_id" IS 'Canonical identifier of the merchant-user association.';
-- Set comment to column: "merchant_id" on table: "merchant_users"
COMMENT ON COLUMN "merchants"."merchant_users"."merchant_id" IS 'Merchant context.';
-- Set comment to column: "user_id" on table: "merchant_users"
COMMENT ON COLUMN "merchants"."merchant_users"."user_id" IS 'Platform user associated with the merchant.';
-- Set comment to column: "merchant_user_status" on table: "merchant_users"
COMMENT ON COLUMN "merchants"."merchant_users"."merchant_user_status" IS 'Association lifecycle status.';
-- Set comment to column: "merchant_user_type" on table: "merchant_users"
COMMENT ON COLUMN "merchants"."merchant_users"."merchant_user_type" IS 'Merchant-side user classification.';
-- Set comment to column: "can_request_coupon" on table: "merchant_users"
COMMENT ON COLUMN "merchants"."merchant_users"."can_request_coupon" IS 'Indicates whether the user may request coupon application.';
-- Set comment to column: "can_manage_coupon" on table: "merchant_users"
COMMENT ON COLUMN "merchants"."merchant_users"."can_manage_coupon" IS 'Indicates whether the user may manage coupon setup, subject to RBAC.';
-- Set comment to column: "can_view_wallet" on table: "merchant_users"
COMMENT ON COLUMN "merchants"."merchant_users"."can_view_wallet" IS 'Indicates whether the user may view merchant wallet context, subject to RBAC.';
-- Set comment to column: "can_view_reports" on table: "merchant_users"
COMMENT ON COLUMN "merchants"."merchant_users"."can_view_reports" IS 'Indicates whether the user may view merchant reports, subject to RBAC.';
-- Set comment to column: "effective_from" on table: "merchant_users"
COMMENT ON COLUMN "merchants"."merchant_users"."effective_from" IS 'Start of association effectiveness.';
-- Set comment to column: "effective_to" on table: "merchant_users"
COMMENT ON COLUMN "merchants"."merchant_users"."effective_to" IS 'End of association effectiveness.';
-- Set comment to column: "invited_at" on table: "merchant_users"
COMMENT ON COLUMN "merchants"."merchant_users"."invited_at" IS 'Timestamp when association was invited.';
-- Set comment to column: "accepted_at" on table: "merchant_users"
COMMENT ON COLUMN "merchants"."merchant_users"."accepted_at" IS 'Timestamp when association was accepted.';
-- Set comment to column: "revoked_at" on table: "merchant_users"
COMMENT ON COLUMN "merchants"."merchant_users"."revoked_at" IS 'Timestamp when association was revoked.';
-- Set comment to column: "revoked_by_user_id" on table: "merchant_users"
COMMENT ON COLUMN "merchants"."merchant_users"."revoked_by_user_id" IS 'User who revoked the association.';
-- Set comment to column: "created_at" on table: "merchant_users"
COMMENT ON COLUMN "merchants"."merchant_users"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "merchant_users"
COMMENT ON COLUMN "merchants"."merchant_users"."created_by_user_id" IS 'User who created the association.';
-- Set comment to column: "created_by_service_identity_id" on table: "merchant_users"
COMMENT ON COLUMN "merchants"."merchant_users"."created_by_service_identity_id" IS 'Service identity that created the association.';
-- Set comment to column: "updated_at" on table: "merchant_users"
COMMENT ON COLUMN "merchants"."merchant_users"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "merchant_users"
COMMENT ON COLUMN "merchants"."merchant_users"."updated_by_user_id" IS 'User who last updated the association.';
-- Set comment to column: "updated_by_service_identity_id" on table: "merchant_users"
COMMENT ON COLUMN "merchants"."merchant_users"."updated_by_service_identity_id" IS 'Service identity that last updated the association.';
-- Set comment to column: "row_version" on table: "merchant_users"
COMMENT ON COLUMN "merchants"."merchant_users"."row_version" IS 'Optimistic concurrency version.';
-- Create "merchant_wallets" table
CREATE TABLE "merchants"."merchant_wallets" (
  "merchant_wallet_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "merchant_id" uuid NOT NULL,
  "wallet_code" character varying(64) NOT NULL,
  "wallet_name" character varying(128) NOT NULL,
  "wallet_type" "merchants"."merchant_wallet_type_enum" NOT NULL,
  "wallet_status" "merchants"."merchant_wallet_status_enum" NOT NULL,
  "currency_code" character(3) NOT NULL,
  "available_balance" numeric(18,2) NULL,
  "reserved_balance" numeric(18,2) NULL,
  "committed_balance" numeric(18,2) NULL,
  "external_ledger_ref" character varying(128) NULL,
  "allows_coupon_funding" boolean NOT NULL DEFAULT false,
  "allows_statutory_discount_funding" boolean NOT NULL DEFAULT false,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_merchant_wallets" PRIMARY KEY ("merchant_wallet_id"),
  CONSTRAINT "uq_merchant_wallets__merchant_wallet_code" UNIQUE ("merchant_id", "wallet_code")
);
-- Create index "ix_merchant_wallets__merchant_id" to table: "merchant_wallets"
CREATE INDEX "ix_merchant_wallets__merchant_id" ON "merchants"."merchant_wallets" ("merchant_id");
-- Create index "ix_merchant_wallets__wallet_status" to table: "merchant_wallets"
CREATE INDEX "ix_merchant_wallets__wallet_status" ON "merchants"."merchant_wallets" ("wallet_status");
-- Create index "ux_merchant_wallets__active_currency_type" to table: "merchant_wallets"
CREATE UNIQUE INDEX "ux_merchant_wallets__active_currency_type" ON "merchants"."merchant_wallets" ("merchant_id", "currency_code", "wallet_type") WHERE (wallet_status = 'ACTIVE'::merchants.merchant_wallet_status_enum);
-- Set comment to table: "merchant_wallets"
COMMENT ON TABLE "merchants"."merchant_wallets" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "merchant_wallet_id" on table: "merchant_wallets"
COMMENT ON COLUMN "merchants"."merchant_wallets"."merchant_wallet_id" IS 'Canonical identifier of the merchant wallet or sponsorship funding context.';
-- Set comment to column: "merchant_id" on table: "merchant_wallets"
COMMENT ON COLUMN "merchants"."merchant_wallets"."merchant_id" IS 'Merchant that owns the wallet context.';
-- Set comment to column: "wallet_code" on table: "merchant_wallets"
COMMENT ON COLUMN "merchants"."merchant_wallets"."wallet_code" IS 'Stable wallet or funding context code.';
-- Set comment to column: "wallet_name" on table: "merchant_wallets"
COMMENT ON COLUMN "merchants"."merchant_wallets"."wallet_name" IS 'Human-readable wallet name.';
-- Set comment to column: "wallet_type" on table: "merchant_wallets"
COMMENT ON COLUMN "merchants"."merchant_wallets"."wallet_type" IS 'Wallet or funding context type.';
-- Set comment to column: "wallet_status" on table: "merchant_wallets"
COMMENT ON COLUMN "merchants"."merchant_wallets"."wallet_status" IS 'Wallet lifecycle status.';
-- Set comment to column: "currency_code" on table: "merchant_wallets"
COMMENT ON COLUMN "merchants"."merchant_wallets"."currency_code" IS 'Wallet currency.';
-- Set comment to column: "available_balance" on table: "merchant_wallets"
COMMENT ON COLUMN "merchants"."merchant_wallets"."available_balance" IS 'Available commercial sponsorship balance, if locally tracked.';
-- Set comment to column: "reserved_balance" on table: "merchant_wallets"
COMMENT ON COLUMN "merchants"."merchant_wallets"."reserved_balance" IS 'Reserved amount for pending coupon applications, if locally tracked.';
-- Set comment to column: "committed_balance" on table: "merchant_wallets"
COMMENT ON COLUMN "merchants"."merchant_wallets"."committed_balance" IS 'Committed or consumed sponsorship value, if locally tracked.';
-- Set comment to column: "external_ledger_ref" on table: "merchant_wallets"
COMMENT ON COLUMN "merchants"."merchant_wallets"."external_ledger_ref" IS 'External ledger or wallet reference, if ledger is externalized.';
-- Set comment to column: "allows_coupon_funding" on table: "merchant_wallets"
COMMENT ON COLUMN "merchants"."merchant_wallets"."allows_coupon_funding" IS 'Indicates whether wallet may fund merchant coupons.';
-- Set comment to column: "allows_statutory_discount_funding" on table: "merchant_wallets"
COMMENT ON COLUMN "merchants"."merchant_wallets"."allows_statutory_discount_funding" IS 'Must be false. Merchant wallets must not fund statutory discounts.';
-- Set comment to column: "effective_from" on table: "merchant_wallets"
COMMENT ON COLUMN "merchants"."merchant_wallets"."effective_from" IS 'Start of wallet effectiveness.';
-- Set comment to column: "effective_to" on table: "merchant_wallets"
COMMENT ON COLUMN "merchants"."merchant_wallets"."effective_to" IS 'End of wallet effectiveness.';
-- Set comment to column: "created_at" on table: "merchant_wallets"
COMMENT ON COLUMN "merchants"."merchant_wallets"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "merchant_wallets"
COMMENT ON COLUMN "merchants"."merchant_wallets"."created_by_user_id" IS 'User who created the wallet context.';
-- Set comment to column: "created_by_service_identity_id" on table: "merchant_wallets"
COMMENT ON COLUMN "merchants"."merchant_wallets"."created_by_service_identity_id" IS 'Service identity that created the wallet context.';
-- Set comment to column: "updated_at" on table: "merchant_wallets"
COMMENT ON COLUMN "merchants"."merchant_wallets"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "merchant_wallets"
COMMENT ON COLUMN "merchants"."merchant_wallets"."updated_by_user_id" IS 'User who last updated the wallet context.';
-- Set comment to column: "updated_by_service_identity_id" on table: "merchant_wallets"
COMMENT ON COLUMN "merchants"."merchant_wallets"."updated_by_service_identity_id" IS 'Service identity that last updated the wallet context.';
-- Set comment to column: "row_version" on table: "merchant_wallets"
COMMENT ON COLUMN "merchants"."merchant_wallets"."row_version" IS 'Optimistic concurrency version.';
-- Create "merchants" table
CREATE TABLE "merchants"."merchants" (
  "merchant_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "merchant_code" character varying(64) NOT NULL,
  "merchant_name" character varying(256) NOT NULL,
  "merchant_display_name" character varying(128) NULL,
  "merchant_type" "merchants"."merchant_type_enum" NOT NULL,
  "merchant_status" "merchants"."merchant_status_enum" NOT NULL,
  "tax_identification_number_hash" character(64) NULL,
  "contact_email" character varying(256) NULL,
  "contact_mobile_masked" character varying(32) NULL,
  "default_currency_code" character(3) NOT NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_merchants" PRIMARY KEY ("merchant_id"),
  CONSTRAINT "uq_merchants__merchant_code" UNIQUE ("merchant_code")
);
-- Create index "ix_merchants__merchant_status" to table: "merchants"
CREATE INDEX "ix_merchants__merchant_status" ON "merchants"."merchants" ("merchant_status");
-- Set comment to table: "merchants"
COMMENT ON TABLE "merchants"."merchants" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "merchant_id" on table: "merchants"
COMMENT ON COLUMN "merchants"."merchants"."merchant_id" IS 'Canonical identifier of the merchant.';
-- Set comment to column: "merchant_code" on table: "merchants"
COMMENT ON COLUMN "merchants"."merchants"."merchant_code" IS 'Stable internal merchant code.';
-- Set comment to column: "merchant_name" on table: "merchants"
COMMENT ON COLUMN "merchants"."merchants"."merchant_name" IS 'Legal or operating merchant name.';
-- Set comment to column: "merchant_display_name" on table: "merchants"
COMMENT ON COLUMN "merchants"."merchants"."merchant_display_name" IS 'Short display name used in UI or reports.';
-- Set comment to column: "merchant_type" on table: "merchants"
COMMENT ON COLUMN "merchants"."merchants"."merchant_type" IS 'Merchant classification.';
-- Set comment to column: "merchant_status" on table: "merchants"
COMMENT ON COLUMN "merchants"."merchants"."merchant_status" IS 'Merchant lifecycle status.';
-- Set comment to column: "tax_identification_number_hash" on table: "merchants"
COMMENT ON COLUMN "merchants"."merchants"."tax_identification_number_hash" IS 'Hash of merchant TIN or equivalent identifier, where retained.';
-- Set comment to column: "contact_email" on table: "merchants"
COMMENT ON COLUMN "merchants"."merchants"."contact_email" IS 'Merchant contact email.';
-- Set comment to column: "contact_mobile_masked" on table: "merchants"
COMMENT ON COLUMN "merchants"."merchants"."contact_mobile_masked" IS 'Masked merchant contact number.';
-- Set comment to column: "default_currency_code" on table: "merchants"
COMMENT ON COLUMN "merchants"."merchants"."default_currency_code" IS 'Default currency for merchant-sponsored benefits.';
-- Set comment to column: "effective_from" on table: "merchants"
COMMENT ON COLUMN "merchants"."merchants"."effective_from" IS 'Start of merchant effectiveness.';
-- Set comment to column: "effective_to" on table: "merchants"
COMMENT ON COLUMN "merchants"."merchants"."effective_to" IS 'End of merchant effectiveness.';
-- Set comment to column: "created_at" on table: "merchants"
COMMENT ON COLUMN "merchants"."merchants"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "merchants"
COMMENT ON COLUMN "merchants"."merchants"."created_by_user_id" IS 'User who created the merchant.';
-- Set comment to column: "created_by_service_identity_id" on table: "merchants"
COMMENT ON COLUMN "merchants"."merchants"."created_by_service_identity_id" IS 'Service identity that created the merchant.';
-- Set comment to column: "updated_at" on table: "merchants"
COMMENT ON COLUMN "merchants"."merchants"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "merchants"
COMMENT ON COLUMN "merchants"."merchants"."updated_by_user_id" IS 'User who last updated the merchant.';
-- Set comment to column: "updated_by_service_identity_id" on table: "merchants"
COMMENT ON COLUMN "merchants"."merchants"."updated_by_service_identity_id" IS 'Service identity that last updated the merchant.';
-- Set comment to column: "row_version" on table: "merchants"
COMMENT ON COLUMN "merchants"."merchants"."row_version" IS 'Optimistic concurrency version.';
-- Create enum type "incident_severity_enum"
CREATE TYPE "operations"."incident_severity_enum" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL');
-- Create enum type "incident_status_enum"
CREATE TYPE "operations"."incident_status_enum" AS ENUM ('OPEN', 'ACKNOWLEDGED', 'INVESTIGATING', 'MITIGATED', 'RESOLVED', 'CLOSED', 'CANCELLED');
-- Create enum type "manual_gate_action_status_enum"
CREATE TYPE "operations"."manual_gate_action_status_enum" AS ENUM ('RECORDED', 'COMPLETED', 'FAILED', 'CANCELLED', 'UNDER_REVIEW', 'RECONCILED');
-- Create enum type "manual_gate_action_type_enum"
CREATE TYPE "operations"."manual_gate_action_type_enum" AS ENUM ('MANUAL_OPEN', 'MANUAL_RELEASE', 'EMERGENCY_OPEN', 'MOPS_RELEASE', 'SUPERVISOR_RELEASE', 'DEVICE_FAILURE_RELEASE', 'INCIDENT_RELEASE');
-- Create enum type "operator_action_status_enum"
CREATE TYPE "operations"."operator_action_status_enum" AS ENUM ('RECORDED', 'SUCCESS', 'FAILED', 'DENIED', 'CANCELLED');
-- Create enum type "operator_action_type_enum"
CREATE TYPE "operations"."operator_action_type_enum" AS ENUM ('SENSITIVE_EVIDENCE_VIEW', 'INCIDENT_ASSIGN', 'INCIDENT_UPDATE', 'RECONCILIATION_REVIEW', 'CONTROLLED_RECHECK', 'PROVIDER_STATUS_QUERY_TRIGGERED', 'SUPPORT_NOTE_ADDED', 'REPORT_EXPORTED', 'CONFIGURATION_VIEW', 'SECURITY_REVIEW');
-- Create enum type "override_approval_decision_enum"
CREATE TYPE "operations"."override_approval_decision_enum" AS ENUM ('APPROVED', 'REJECTED', 'ESCALATED', 'CANCELLED', 'EXPIRED');
-- Create enum type "override_request_status_enum"
CREATE TYPE "operations"."override_request_status_enum" AS ENUM ('REQUESTED', 'PENDING_APPROVAL', 'APPROVED', 'REJECTED', 'CANCELLED', 'EXPIRED', 'EXECUTED', 'CLOSED');
-- Create enum type "override_type_enum"
CREATE TYPE "operations"."override_type_enum" AS ENUM ('MANUAL_GATE_OPEN', 'EXIT_AUTHORIZATION_REISSUE', 'COUPON_EXCEPTION', 'STATUTORY_DISCOUNT_REVIEW_EXCEPTION', 'INCIDENT_RELEASE', 'CONTINUITY_ACTION', 'RECONCILIATION_CORRECTION', 'SUPPORT_ACTION');
-- Create "record_manual_gate_log" function
CREATE FUNCTION "operations"."record_manual_gate_log" () RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'operations.record_manual_gate_log is a v1.2 routine placeholder and must be implemented before production use'; END; $$;
-- Create "incident_records" table
CREATE TABLE "operations"."incident_records" (
  "incident_record_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "incident_code" character varying(64) NOT NULL,
  "incident_title" character varying(256) NOT NULL,
  "incident_description" text NULL,
  "incident_category" character varying(64) NOT NULL,
  "incident_severity" "operations"."incident_severity_enum" NOT NULL,
  "incident_status" "operations"."incident_status_enum" NOT NULL,
  "site_group_id" uuid NULL,
  "site_id" uuid NULL,
  "lane_id" uuid NULL,
  "gate_device_id" uuid NULL,
  "vendor_system_id" uuid NULL,
  "payment_rail_id" uuid NULL,
  "started_at" timestamptz NOT NULL DEFAULT now(),
  "detected_at" timestamptz NOT NULL,
  "resolved_at" timestamptz NULL,
  "closed_at" timestamptz NULL,
  "closure_reason_code" character varying(64) NULL,
  "owner_user_id" uuid NULL,
  "owner_service_identity_id" uuid NULL,
  "requires_reconciliation" boolean NOT NULL DEFAULT false,
  "requires_post_incident_review" boolean NOT NULL DEFAULT false,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_incident_records" PRIMARY KEY ("incident_record_id")
);
-- Create index "ix_incident_records__correlation_id" to table: "incident_records"
CREATE INDEX "ix_incident_records__correlation_id" ON "operations"."incident_records" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_incident_records__gate_device_id" to table: "incident_records"
CREATE INDEX "ix_incident_records__gate_device_id" ON "operations"."incident_records" ("gate_device_id");
-- Create index "ix_incident_records__lane_id" to table: "incident_records"
CREATE INDEX "ix_incident_records__lane_id" ON "operations"."incident_records" ("lane_id");
-- Create index "ix_incident_records__site_group_id" to table: "incident_records"
CREATE INDEX "ix_incident_records__site_group_id" ON "operations"."incident_records" ("site_group_id");
-- Create index "ix_incident_records__site_id" to table: "incident_records"
CREATE INDEX "ix_incident_records__site_id" ON "operations"."incident_records" ("site_id");
-- Set comment to table: "incident_records"
COMMENT ON TABLE "operations"."incident_records" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "incident_record_id" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."incident_record_id" IS 'Canonical identifier of the incident.';
-- Set comment to column: "incident_code" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."incident_code" IS 'Human-readable or generated incident code.';
-- Set comment to column: "incident_title" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."incident_title" IS 'Short incident title.';
-- Set comment to column: "incident_description" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."incident_description" IS 'Incident description.';
-- Set comment to column: "incident_category" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."incident_category" IS 'Controlled incident category.';
-- Set comment to column: "incident_severity" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."incident_severity" IS 'Incident severity.';
-- Set comment to column: "incident_status" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."incident_status" IS 'Incident lifecycle state.';
-- Set comment to column: "site_group_id" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."site_group_id" IS 'Affected site group, where applicable.';
-- Set comment to column: "site_id" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."site_id" IS 'Affected site, where applicable.';
-- Set comment to column: "lane_id" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."lane_id" IS 'Affected lane, where applicable.';
-- Set comment to column: "gate_device_id" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."gate_device_id" IS 'Affected gate device, where applicable.';
-- Set comment to column: "vendor_system_id" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."vendor_system_id" IS 'Affected vendor system, where applicable.';
-- Set comment to column: "payment_rail_id" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."payment_rail_id" IS 'Affected payment rail, where applicable.';
-- Set comment to column: "started_at" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."started_at" IS 'Incident start timestamp.';
-- Set comment to column: "detected_at" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."detected_at" IS 'Incident detection timestamp.';
-- Set comment to column: "resolved_at" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."resolved_at" IS 'Incident technical resolution timestamp.';
-- Set comment to column: "closed_at" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."closed_at" IS 'Incident closure timestamp.';
-- Set comment to column: "closure_reason_code" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."closure_reason_code" IS 'Controlled closure reason.';
-- Set comment to column: "owner_user_id" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."owner_user_id" IS 'User assigned as incident owner.';
-- Set comment to column: "owner_service_identity_id" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."owner_service_identity_id" IS 'Service identity assigned as owner, where automated.';
-- Set comment to column: "requires_reconciliation" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."requires_reconciliation" IS 'Indicates whether incident requires reconciliation.';
-- Set comment to column: "requires_post_incident_review" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."requires_post_incident_review" IS 'Indicates whether post-incident review is required.';
-- Set comment to column: "correlation_id" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."created_by_user_id" IS 'User who created the incident.';
-- Set comment to column: "created_by_service_identity_id" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."created_by_service_identity_id" IS 'Service identity that created the incident.';
-- Set comment to column: "updated_at" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."updated_by_user_id" IS 'User who last updated the incident.';
-- Set comment to column: "updated_by_service_identity_id" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."updated_by_service_identity_id" IS 'Service identity that last updated the incident.';
-- Set comment to column: "row_version" on table: "incident_records"
COMMENT ON COLUMN "operations"."incident_records"."row_version" IS 'Optimistic concurrency version.';
-- Create "manual_gate_logs" table
CREATE TABLE "operations"."manual_gate_logs" (
  "manual_gate_log_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "parking_session_id" uuid NULL,
  "exit_authorization_id" uuid NULL,
  "gate_authorization_consumption_id" uuid NULL,
  "incident_record_id" uuid NULL,
  "override_approval_id" uuid NULL,
  "site_id" uuid NOT NULL,
  "lane_id" uuid NULL,
  "gate_device_id" uuid NULL,
  "manual_action_type" "operations"."manual_gate_action_type_enum" NOT NULL,
  "manual_action_status" "operations"."manual_gate_action_status_enum" NOT NULL,
  "manual_reason_code" character varying(64) NOT NULL,
  "operator_notes" text NULL,
  "requires_reconciliation" boolean NOT NULL DEFAULT false,
  "reconciliation_item_id" uuid NULL,
  "performed_at" timestamptz NOT NULL,
  "performed_by_user_id" uuid NOT NULL,
  "recorded_at" timestamptz NOT NULL DEFAULT now(),
  "recorded_by_user_id" uuid NULL,
  "recorded_by_service_identity_id" uuid NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_manual_gate_logs" PRIMARY KEY ("manual_gate_log_id")
);
-- Create index "ix_manual_gate_logs__correlation_id" to table: "manual_gate_logs"
CREATE INDEX "ix_manual_gate_logs__correlation_id" ON "operations"."manual_gate_logs" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_manual_gate_logs__exit_authorization_id" to table: "manual_gate_logs"
CREATE INDEX "ix_manual_gate_logs__exit_authorization_id" ON "operations"."manual_gate_logs" ("exit_authorization_id");
-- Create index "ix_manual_gate_logs__incident_record_id" to table: "manual_gate_logs"
CREATE INDEX "ix_manual_gate_logs__incident_record_id" ON "operations"."manual_gate_logs" ("incident_record_id");
-- Create index "ix_manual_gate_logs__lane_id" to table: "manual_gate_logs"
CREATE INDEX "ix_manual_gate_logs__lane_id" ON "operations"."manual_gate_logs" ("lane_id");
-- Create index "ix_manual_gate_logs__override_approval_id" to table: "manual_gate_logs"
CREATE INDEX "ix_manual_gate_logs__override_approval_id" ON "operations"."manual_gate_logs" ("override_approval_id");
-- Create index "ix_manual_gate_logs__parking_session_id" to table: "manual_gate_logs"
CREATE INDEX "ix_manual_gate_logs__parking_session_id" ON "operations"."manual_gate_logs" ("parking_session_id");
-- Create index "ix_manual_gate_logs__site_id" to table: "manual_gate_logs"
CREATE INDEX "ix_manual_gate_logs__site_id" ON "operations"."manual_gate_logs" ("site_id");
-- Set comment to table: "manual_gate_logs"
COMMENT ON TABLE "operations"."manual_gate_logs" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "manual_gate_log_id" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."manual_gate_log_id" IS 'Canonical identifier of the manual gate log.';
-- Set comment to column: "parking_session_id" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."parking_session_id" IS 'Related parking session, where known.';
-- Set comment to column: "exit_authorization_id" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."exit_authorization_id" IS 'Related exit authorization, where known.';
-- Set comment to column: "gate_authorization_consumption_id" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."gate_authorization_consumption_id" IS 'Related failed or uncertain consume attempt, where applicable.';
-- Set comment to column: "incident_record_id" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."incident_record_id" IS 'Incident that caused or justified the manual action.';
-- Set comment to column: "override_approval_id" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."override_approval_id" IS 'Approval record authorizing the manual action, where required.';
-- Set comment to column: "site_id" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."site_id" IS 'Site where manual gate action occurred.';
-- Set comment to column: "lane_id" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."lane_id" IS 'Lane where manual gate action occurred.';
-- Set comment to column: "gate_device_id" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."gate_device_id" IS 'Gate device involved, where known.';
-- Set comment to column: "manual_action_type" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."manual_action_type" IS 'Type of manual gate action.';
-- Set comment to column: "manual_action_status" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."manual_action_status" IS 'Result of manual action.';
-- Set comment to column: "manual_reason_code" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."manual_reason_code" IS 'Controlled reason for manual action.';
-- Set comment to column: "operator_notes" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."operator_notes" IS 'Controlled operational note. Must not store sensitive evidence casually.';
-- Set comment to column: "requires_reconciliation" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."requires_reconciliation" IS 'Indicates whether the action requires reconciliation or review.';
-- Set comment to column: "reconciliation_item_id" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."reconciliation_item_id" IS 'Reconciliation item created for review or closure.';
-- Set comment to column: "performed_at" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."performed_at" IS 'Timestamp when manual action occurred.';
-- Set comment to column: "performed_by_user_id" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."performed_by_user_id" IS 'Operator who performed the manual action.';
-- Set comment to column: "recorded_at" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."recorded_at" IS 'Timestamp when the action was recorded.';
-- Set comment to column: "recorded_by_user_id" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."recorded_by_user_id" IS 'User who recorded the action.';
-- Set comment to column: "recorded_by_service_identity_id" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."recorded_by_service_identity_id" IS 'Service identity that recorded the action.';
-- Set comment to column: "correlation_id" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."created_by_user_id" IS 'User who created the record.';
-- Set comment to column: "created_by_service_identity_id" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."created_by_service_identity_id" IS 'Service identity that created the record.';
-- Set comment to column: "updated_at" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."updated_by_user_id" IS 'User who last updated the record.';
-- Set comment to column: "updated_by_service_identity_id" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."updated_by_service_identity_id" IS 'Service identity that last updated the record.';
-- Set comment to column: "row_version" on table: "manual_gate_logs"
COMMENT ON COLUMN "operations"."manual_gate_logs"."row_version" IS 'Optimistic concurrency version.';
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
);
-- Create index "ix_operator_action_logs__correlation_id" to table: "operator_action_logs"
CREATE INDEX "ix_operator_action_logs__correlation_id" ON "operations"."operator_action_logs" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_operator_action_logs__operator_user_id" to table: "operator_action_logs"
CREATE INDEX "ix_operator_action_logs__operator_user_id" ON "operations"."operator_action_logs" ("operator_user_id");
-- Create index "ix_operator_action_logs__site_id" to table: "operator_action_logs"
CREATE INDEX "ix_operator_action_logs__site_id" ON "operations"."operator_action_logs" ("site_id");
-- Set comment to table: "operator_action_logs"
COMMENT ON TABLE "operations"."operator_action_logs" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "operator_action_log_id" on table: "operator_action_logs"
COMMENT ON COLUMN "operations"."operator_action_logs"."operator_action_log_id" IS 'Canonical identifier of the operator action log.';
-- Set comment to column: "operator_user_id" on table: "operator_action_logs"
COMMENT ON COLUMN "operations"."operator_action_logs"."operator_user_id" IS 'User who performed the action.';
-- Set comment to column: "action_type" on table: "operator_action_logs"
COMMENT ON COLUMN "operations"."operator_action_logs"."action_type" IS 'Type of operator action.';
-- Set comment to column: "action_reason_code" on table: "operator_action_logs"
COMMENT ON COLUMN "operations"."operator_action_logs"."action_reason_code" IS 'Controlled reason for the action.';
-- Set comment to column: "target_entity_type" on table: "operator_action_logs"
COMMENT ON COLUMN "operations"."operator_action_logs"."target_entity_type" IS 'Type of affected entity.';
-- Set comment to column: "target_entity_id" on table: "operator_action_logs"
COMMENT ON COLUMN "operations"."operator_action_logs"."target_entity_id" IS 'Affected entity identifier.';
-- Set comment to column: "site_id" on table: "operator_action_logs"
COMMENT ON COLUMN "operations"."operator_action_logs"."site_id" IS 'Site context, where applicable.';
-- Set comment to column: "incident_record_id" on table: "operator_action_logs"
COMMENT ON COLUMN "operations"."operator_action_logs"."incident_record_id" IS 'Related incident, where applicable.';
-- Set comment to column: "action_status" on table: "operator_action_logs"
COMMENT ON COLUMN "operations"."operator_action_logs"."action_status" IS 'Result of action.';
-- Set comment to column: "action_notes" on table: "operator_action_logs"
COMMENT ON COLUMN "operations"."operator_action_logs"."action_notes" IS 'Controlled note. Must not store sensitive evidence casually.';
-- Set comment to column: "performed_at" on table: "operator_action_logs"
COMMENT ON COLUMN "operations"."operator_action_logs"."performed_at" IS 'Timestamp when operator action occurred.';
-- Set comment to column: "correlation_id" on table: "operator_action_logs"
COMMENT ON COLUMN "operations"."operator_action_logs"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "operator_action_logs"
COMMENT ON COLUMN "operations"."operator_action_logs"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "operator_action_logs"
COMMENT ON COLUMN "operations"."operator_action_logs"."created_by_user_id" IS 'User who created the log.';
-- Set comment to column: "created_by_service_identity_id" on table: "operator_action_logs"
COMMENT ON COLUMN "operations"."operator_action_logs"."created_by_service_identity_id" IS 'Service identity that created the log.';
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
);
-- Create index "ix_override_approvals__correlation_id" to table: "override_approvals"
CREATE INDEX "ix_override_approvals__correlation_id" ON "operations"."override_approvals" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_override_approvals__decided_by_user_id" to table: "override_approvals"
CREATE INDEX "ix_override_approvals__decided_by_user_id" ON "operations"."override_approvals" ("decided_by_user_id");
-- Create index "ix_override_approvals__override_request_id" to table: "override_approvals"
CREATE INDEX "ix_override_approvals__override_request_id" ON "operations"."override_approvals" ("override_request_id");
-- Set comment to table: "override_approvals"
COMMENT ON TABLE "operations"."override_approvals" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "override_approval_id" on table: "override_approvals"
COMMENT ON COLUMN "operations"."override_approvals"."override_approval_id" IS 'Canonical identifier of the approval record.';
-- Set comment to column: "override_request_id" on table: "override_approvals"
COMMENT ON COLUMN "operations"."override_approvals"."override_request_id" IS 'Override request being reviewed.';
-- Set comment to column: "approval_sequence" on table: "override_approvals"
COMMENT ON COLUMN "operations"."override_approvals"."approval_sequence" IS 'Approval sequence or level.';
-- Set comment to column: "approval_decision" on table: "override_approvals"
COMMENT ON COLUMN "operations"."override_approvals"."approval_decision" IS 'Approval decision.';
-- Set comment to column: "approval_reason_code" on table: "override_approvals"
COMMENT ON COLUMN "operations"."override_approvals"."approval_reason_code" IS 'Controlled approval reason.';
-- Set comment to column: "rejection_reason_code" on table: "override_approvals"
COMMENT ON COLUMN "operations"."override_approvals"."rejection_reason_code" IS 'Controlled rejection reason.';
-- Set comment to column: "approval_notes" on table: "override_approvals"
COMMENT ON COLUMN "operations"."override_approvals"."approval_notes" IS 'Controlled note. Must not store sensitive evidence casually.';
-- Set comment to column: "decided_at" on table: "override_approvals"
COMMENT ON COLUMN "operations"."override_approvals"."decided_at" IS 'Timestamp when decision was made.';
-- Set comment to column: "decided_by_user_id" on table: "override_approvals"
COMMENT ON COLUMN "operations"."override_approvals"."decided_by_user_id" IS 'User who approved, rejected, escalated, or cancelled.';
-- Set comment to column: "expires_at" on table: "override_approvals"
COMMENT ON COLUMN "operations"."override_approvals"."expires_at" IS 'Expiry timestamp for approval usability.';
-- Set comment to column: "correlation_id" on table: "override_approvals"
COMMENT ON COLUMN "operations"."override_approvals"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "override_approvals"
COMMENT ON COLUMN "operations"."override_approvals"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "override_approvals"
COMMENT ON COLUMN "operations"."override_approvals"."created_by_user_id" IS 'User who created the approval record.';
-- Set comment to column: "created_by_service_identity_id" on table: "override_approvals"
COMMENT ON COLUMN "operations"."override_approvals"."created_by_service_identity_id" IS 'Service identity that created the approval record.';
-- Create "override_requests" table
CREATE TABLE "operations"."override_requests" (
  "override_request_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "incident_record_id" uuid NULL,
  "target_entity_type" character varying(64) NULL,
  "target_entity_id" uuid NULL,
  "site_id" uuid NULL,
  "lane_id" uuid NULL,
  "override_type" "operations"."override_type_enum" NOT NULL,
  "override_reason_code" character varying(64) NOT NULL,
  "request_status" "operations"."override_request_status_enum" NOT NULL,
  "request_notes" text NULL,
  "requires_approval" boolean NOT NULL DEFAULT false,
  "requested_at" timestamptz NOT NULL,
  "requested_by_user_id" uuid NOT NULL,
  "expires_at" timestamptz NULL,
  "closed_at" timestamptz NULL,
  "closure_reason_code" character varying(64) NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_override_requests" PRIMARY KEY ("override_request_id")
);
-- Create index "ix_override_requests__correlation_id" to table: "override_requests"
CREATE INDEX "ix_override_requests__correlation_id" ON "operations"."override_requests" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_override_requests__incident_record_id" to table: "override_requests"
CREATE INDEX "ix_override_requests__incident_record_id" ON "operations"."override_requests" ("incident_record_id");
-- Create index "ix_override_requests__lane_id" to table: "override_requests"
CREATE INDEX "ix_override_requests__lane_id" ON "operations"."override_requests" ("lane_id");
-- Create index "ix_override_requests__requested_by_user_id" to table: "override_requests"
CREATE INDEX "ix_override_requests__requested_by_user_id" ON "operations"."override_requests" ("requested_by_user_id");
-- Create index "ix_override_requests__site_id" to table: "override_requests"
CREATE INDEX "ix_override_requests__site_id" ON "operations"."override_requests" ("site_id");
-- Set comment to table: "override_requests"
COMMENT ON TABLE "operations"."override_requests" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "override_request_id" on table: "override_requests"
COMMENT ON COLUMN "operations"."override_requests"."override_request_id" IS 'Canonical identifier of the override request.';
-- Set comment to column: "incident_record_id" on table: "override_requests"
COMMENT ON COLUMN "operations"."override_requests"."incident_record_id" IS 'Related incident, where applicable.';
-- Set comment to column: "target_entity_type" on table: "override_requests"
COMMENT ON COLUMN "operations"."override_requests"."target_entity_type" IS 'Type of affected entity.';
-- Set comment to column: "target_entity_id" on table: "override_requests"
COMMENT ON COLUMN "operations"."override_requests"."target_entity_id" IS 'Identifier of affected entity.';
-- Set comment to column: "site_id" on table: "override_requests"
COMMENT ON COLUMN "operations"."override_requests"."site_id" IS 'Site affected by the override request.';
-- Set comment to column: "lane_id" on table: "override_requests"
COMMENT ON COLUMN "operations"."override_requests"."lane_id" IS 'Lane affected by the override request.';
-- Set comment to column: "override_type" on table: "override_requests"
COMMENT ON COLUMN "operations"."override_requests"."override_type" IS 'Type of override requested.';
-- Set comment to column: "override_reason_code" on table: "override_requests"
COMMENT ON COLUMN "operations"."override_requests"."override_reason_code" IS 'Controlled reason for request.';
-- Set comment to column: "request_status" on table: "override_requests"
COMMENT ON COLUMN "operations"."override_requests"."request_status" IS 'Request lifecycle state.';
-- Set comment to column: "request_notes" on table: "override_requests"
COMMENT ON COLUMN "operations"."override_requests"."request_notes" IS 'Controlled operational note. Must not store sensitive evidence casually.';
-- Set comment to column: "requires_approval" on table: "override_requests"
COMMENT ON COLUMN "operations"."override_requests"."requires_approval" IS 'Indicates whether approval is required.';
-- Set comment to column: "requested_at" on table: "override_requests"
COMMENT ON COLUMN "operations"."override_requests"."requested_at" IS 'Timestamp when request was made.';
-- Set comment to column: "requested_by_user_id" on table: "override_requests"
COMMENT ON COLUMN "operations"."override_requests"."requested_by_user_id" IS 'User who requested the override.';
-- Set comment to column: "expires_at" on table: "override_requests"
COMMENT ON COLUMN "operations"."override_requests"."expires_at" IS 'Expiry timestamp for request validity.';
-- Set comment to column: "closed_at" on table: "override_requests"
COMMENT ON COLUMN "operations"."override_requests"."closed_at" IS 'Closure timestamp.';
-- Set comment to column: "closure_reason_code" on table: "override_requests"
COMMENT ON COLUMN "operations"."override_requests"."closure_reason_code" IS 'Controlled closure reason.';
-- Set comment to column: "correlation_id" on table: "override_requests"
COMMENT ON COLUMN "operations"."override_requests"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "override_requests"
COMMENT ON COLUMN "operations"."override_requests"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "override_requests"
COMMENT ON COLUMN "operations"."override_requests"."created_by_user_id" IS 'User who created the request.';
-- Set comment to column: "created_by_service_identity_id" on table: "override_requests"
COMMENT ON COLUMN "operations"."override_requests"."created_by_service_identity_id" IS 'Service identity that created the request.';
-- Set comment to column: "updated_at" on table: "override_requests"
COMMENT ON COLUMN "operations"."override_requests"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "override_requests"
COMMENT ON COLUMN "operations"."override_requests"."updated_by_user_id" IS 'User who last updated the request.';
-- Set comment to column: "updated_by_service_identity_id" on table: "override_requests"
COMMENT ON COLUMN "operations"."override_requests"."updated_by_service_identity_id" IS 'Service identity that last updated the request.';
-- Set comment to column: "row_version" on table: "override_requests"
COMMENT ON COLUMN "operations"."override_requests"."row_version" IS 'Optimistic concurrency version.';
-- Create enum type "central_pms_report_status_enum"
CREATE TYPE "payments"."central_pms_report_status_enum" AS ENUM ('NOT_REPORTED', 'REPORTED', 'ACCEPTED', 'REJECTED', 'FAILED', 'RETRY_PENDING');
-- Create enum type "payment_rail_status_enum"
CREATE TYPE "payments"."payment_rail_status_enum" AS ENUM ('DRAFT', 'ACTIVE', 'SUSPENDED', 'MAINTENANCE', 'DEPRECATED', 'RETIRED');
-- Create enum type "payment_rail_type_enum"
CREATE TYPE "payments"."payment_rail_type_enum" AS ENUM ('QRPH', 'CARD', 'EWALLET', 'HOSTED_CHECKOUT', 'BANK_TRANSFER', 'OTHER');
-- Create enum type "provider_callback_processing_status_enum"
CREATE TYPE "payments"."provider_callback_processing_status_enum" AS ENUM ('RECEIVED', 'PROCESSING', 'PROCESSED', 'DUPLICATE', 'REJECTED', 'FAILED');
-- Create enum type "provider_callback_verification_status_enum"
CREATE TYPE "payments"."provider_callback_verification_status_enum" AS ENUM ('UNVERIFIED', 'VERIFIED', 'FAILED_SIGNATURE', 'FAILED_TIMESTAMP', 'FAILED_SOURCE', 'FAILED_REPLAY', 'FAILED_SCHEMA', 'UNKNOWN');
-- Create enum type "provider_outcome_status_enum"
CREATE TYPE "payments"."provider_outcome_status_enum" AS ENUM ('CONFIRMED', 'FAILED', 'EXPIRED', 'CANCELLED', 'REJECTED', 'UNKNOWN');
-- Create enum type "provider_session_status_enum"
CREATE TYPE "payments"."provider_session_status_enum" AS ENUM ('CREATED', 'ACTIVE', 'PENDING', 'PAID', 'FAILED', 'EXPIRED', 'CANCELLED', 'UNKNOWN');
-- Create enum type "provider_status_query_status_enum"
CREATE TYPE "payments"."provider_status_query_status_enum" AS ENUM ('REQUESTED', 'COMPLETED', 'FAILED', 'TIMEOUT', 'INCONCLUSIVE');
-- Create "payment_rails" table
CREATE TABLE "payments"."payment_rails" (
  "payment_rail_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "rail_code" character varying(64) NOT NULL,
  "rail_name" character varying(128) NOT NULL,
  "provider_code" character varying(64) NOT NULL,
  "rail_type" "payments"."payment_rail_type_enum" NOT NULL,
  "supported_currency_code" character(3) NOT NULL,
  "rail_status" "payments"."payment_rail_status_enum" NOT NULL,
  "is_primary" boolean NOT NULL DEFAULT false,
  "is_fallback" boolean NOT NULL DEFAULT false,
  "provider_profile_ref" character varying(128) NULL,
  "configuration_ref" character varying(128) NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_payment_rails" PRIMARY KEY ("payment_rail_id"),
  CONSTRAINT "uq_payment_rails__rail_code" UNIQUE ("rail_code")
);
-- Create index "ix_payment_rails__rail_status" to table: "payment_rails"
CREATE INDEX "ix_payment_rails__rail_status" ON "payments"."payment_rails" ("rail_status");
-- Set comment to table: "payment_rails"
COMMENT ON TABLE "payments"."payment_rails" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "payment_rail_id" on table: "payment_rails"
COMMENT ON COLUMN "payments"."payment_rails"."payment_rail_id" IS 'Canonical identifier of the payment rail.';
-- Set comment to column: "rail_code" on table: "payment_rails"
COMMENT ON COLUMN "payments"."payment_rails"."rail_code" IS 'Stable internal code for the rail.';
-- Set comment to column: "rail_name" on table: "payment_rails"
COMMENT ON COLUMN "payments"."payment_rails"."rail_name" IS 'Human-readable payment rail name.';
-- Set comment to column: "provider_code" on table: "payment_rails"
COMMENT ON COLUMN "payments"."payment_rails"."provider_code" IS 'Provider code.';
-- Set comment to column: "rail_type" on table: "payment_rails"
COMMENT ON COLUMN "payments"."payment_rails"."rail_type" IS 'Type of rail.';
-- Set comment to column: "supported_currency_code" on table: "payment_rails"
COMMENT ON COLUMN "payments"."payment_rails"."supported_currency_code" IS 'Supported currency.';
-- Set comment to column: "rail_status" on table: "payment_rails"
COMMENT ON COLUMN "payments"."payment_rails"."rail_status" IS 'Lifecycle status of the payment rail.';
-- Set comment to column: "is_primary" on table: "payment_rails"
COMMENT ON COLUMN "payments"."payment_rails"."is_primary" IS 'Indicates whether this is the preferred rail for its type.';
-- Set comment to column: "is_fallback" on table: "payment_rails"
COMMENT ON COLUMN "payments"."payment_rails"."is_fallback" IS 'Indicates whether this rail may be used as fallback.';
-- Set comment to column: "provider_profile_ref" on table: "payment_rails"
COMMENT ON COLUMN "payments"."payment_rails"."provider_profile_ref" IS 'External or internal provider profile reference.';
-- Set comment to column: "configuration_ref" on table: "payment_rails"
COMMENT ON COLUMN "payments"."payment_rails"."configuration_ref" IS 'Configuration profile reference.';
-- Set comment to column: "effective_from" on table: "payment_rails"
COMMENT ON COLUMN "payments"."payment_rails"."effective_from" IS 'Start of rail effectiveness.';
-- Set comment to column: "effective_to" on table: "payment_rails"
COMMENT ON COLUMN "payments"."payment_rails"."effective_to" IS 'End of rail effectiveness.';
-- Set comment to column: "created_at" on table: "payment_rails"
COMMENT ON COLUMN "payments"."payment_rails"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "payment_rails"
COMMENT ON COLUMN "payments"."payment_rails"."created_by_user_id" IS 'User who created the rail record.';
-- Set comment to column: "created_by_service_identity_id" on table: "payment_rails"
COMMENT ON COLUMN "payments"."payment_rails"."created_by_service_identity_id" IS 'Service identity that created the rail record.';
-- Set comment to column: "updated_at" on table: "payment_rails"
COMMENT ON COLUMN "payments"."payment_rails"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "payment_rails"
COMMENT ON COLUMN "payments"."payment_rails"."updated_by_user_id" IS 'User who last updated the rail record.';
-- Set comment to column: "updated_by_service_identity_id" on table: "payment_rails"
COMMENT ON COLUMN "payments"."payment_rails"."updated_by_service_identity_id" IS 'Service identity that last updated the rail record.';
-- Set comment to column: "row_version" on table: "payment_rails"
COMMENT ON COLUMN "payments"."payment_rails"."row_version" IS 'Optimistic concurrency version.';
-- Create "provider_callbacks" table
CREATE TABLE "payments"."provider_callbacks" (
  "provider_callback_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "payment_rail_id" uuid NOT NULL,
  "provider_session_id" uuid NULL,
  "payment_attempt_id" uuid NULL,
  "provider_event_ref" character varying(128) NULL,
  "provider_transaction_ref" character varying(128) NULL,
  "callback_type" character varying(64) NOT NULL,
  "payload_hash" character(64) NOT NULL,
  "payload_storage_ref" character varying(256) NULL,
  "headers_hash" character(64) NULL,
  "signature_valid" boolean NULL,
  "timestamp_valid" boolean NULL,
  "source_valid" boolean NULL,
  "verification_status" "payments"."provider_callback_verification_status_enum" NOT NULL,
  "processing_status" "payments"."provider_callback_processing_status_enum" NOT NULL,
  "received_at" timestamptz NOT NULL,
  "processed_at" timestamptz NULL,
  "failure_reason_code" character varying(64) NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  CONSTRAINT "pk_provider_callbacks" PRIMARY KEY ("provider_callback_id")
);
-- Create index "ix_provider_callbacks__correlation_id" to table: "provider_callbacks"
CREATE INDEX "ix_provider_callbacks__correlation_id" ON "payments"."provider_callbacks" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_provider_callbacks__payment_attempt_id" to table: "provider_callbacks"
CREATE INDEX "ix_provider_callbacks__payment_attempt_id" ON "payments"."provider_callbacks" ("payment_attempt_id");
-- Create index "ix_provider_callbacks__payment_rail_id" to table: "provider_callbacks"
CREATE INDEX "ix_provider_callbacks__payment_rail_id" ON "payments"."provider_callbacks" ("payment_rail_id");
-- Create index "ix_provider_callbacks__processing_status" to table: "provider_callbacks"
CREATE INDEX "ix_provider_callbacks__processing_status" ON "payments"."provider_callbacks" ("processing_status");
-- Create index "ix_provider_callbacks__provider_session_id" to table: "provider_callbacks"
CREATE INDEX "ix_provider_callbacks__provider_session_id" ON "payments"."provider_callbacks" ("provider_session_id");
-- Create index "ix_provider_callbacks__received_at" to table: "provider_callbacks"
CREATE INDEX "ix_provider_callbacks__received_at" ON "payments"."provider_callbacks" ("received_at");
-- Create index "ix_provider_callbacks__verification_status" to table: "provider_callbacks"
CREATE INDEX "ix_provider_callbacks__verification_status" ON "payments"."provider_callbacks" ("verification_status");
-- Create index "ux_provider_callbacks__provider_event" to table: "provider_callbacks"
CREATE UNIQUE INDEX "ux_provider_callbacks__provider_event" ON "payments"."provider_callbacks" ("payment_rail_id", "provider_event_ref") WHERE (provider_event_ref IS NOT NULL);
-- Set comment to table: "provider_callbacks"
COMMENT ON TABLE "payments"."provider_callbacks" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "provider_callback_id" on table: "provider_callbacks"
COMMENT ON COLUMN "payments"."provider_callbacks"."provider_callback_id" IS 'Canonical identifier of the provider callback record.';
-- Set comment to column: "payment_rail_id" on table: "provider_callbacks"
COMMENT ON COLUMN "payments"."provider_callbacks"."payment_rail_id" IS 'Payment rail or provider profile that received the callback.';
-- Set comment to column: "provider_session_id" on table: "provider_callbacks"
COMMENT ON COLUMN "payments"."provider_callbacks"."provider_session_id" IS 'Provider session correlated to the callback, where known.';
-- Set comment to column: "payment_attempt_id" on table: "provider_callbacks"
COMMENT ON COLUMN "payments"."provider_callbacks"."payment_attempt_id" IS 'Payment attempt correlated to the callback, where known.';
-- Set comment to column: "provider_event_ref" on table: "provider_callbacks"
COMMENT ON COLUMN "payments"."provider_callbacks"."provider_event_ref" IS 'Provider event ID or callback reference.';
-- Set comment to column: "provider_transaction_ref" on table: "provider_callbacks"
COMMENT ON COLUMN "payments"."provider_callbacks"."provider_transaction_ref" IS 'Provider transaction reference in the callback.';
-- Set comment to column: "callback_type" on table: "provider_callbacks"
COMMENT ON COLUMN "payments"."provider_callbacks"."callback_type" IS 'Provider callback type or normalized event type.';
-- Set comment to column: "payload_hash" on table: "provider_callbacks"
COMMENT ON COLUMN "payments"."provider_callbacks"."payload_hash" IS 'SHA-256 hash of raw callback payload.';
-- Set comment to column: "payload_storage_ref" on table: "provider_callbacks"
COMMENT ON COLUMN "payments"."provider_callbacks"."payload_storage_ref" IS 'Reference to raw payload storage if stored outside table.';
-- Set comment to column: "headers_hash" on table: "provider_callbacks"
COMMENT ON COLUMN "payments"."provider_callbacks"."headers_hash" IS 'Hash of relevant callback headers where retained.';
-- Set comment to column: "signature_valid" on table: "provider_callbacks"
COMMENT ON COLUMN "payments"."provider_callbacks"."signature_valid" IS 'Result of signature verification where applicable.';
-- Set comment to column: "timestamp_valid" on table: "provider_callbacks"
COMMENT ON COLUMN "payments"."provider_callbacks"."timestamp_valid" IS 'Result of timestamp-window verification where applicable.';
-- Set comment to column: "source_valid" on table: "provider_callbacks"
COMMENT ON COLUMN "payments"."provider_callbacks"."source_valid" IS 'Result of source validation where applicable.';
-- Set comment to column: "verification_status" on table: "provider_callbacks"
COMMENT ON COLUMN "payments"."provider_callbacks"."verification_status" IS 'Trust verification result.';
-- Set comment to column: "processing_status" on table: "provider_callbacks"
COMMENT ON COLUMN "payments"."provider_callbacks"."processing_status" IS 'Processing lifecycle state.';
-- Set comment to column: "received_at" on table: "provider_callbacks"
COMMENT ON COLUMN "payments"."provider_callbacks"."received_at" IS 'Timestamp when callback was received.';
-- Set comment to column: "processed_at" on table: "provider_callbacks"
COMMENT ON COLUMN "payments"."provider_callbacks"."processed_at" IS 'Timestamp when callback processing completed.';
-- Set comment to column: "failure_reason_code" on table: "provider_callbacks"
COMMENT ON COLUMN "payments"."provider_callbacks"."failure_reason_code" IS 'Controlled failure reason.';
-- Set comment to column: "correlation_id" on table: "provider_callbacks"
COMMENT ON COLUMN "payments"."provider_callbacks"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "provider_callbacks"
COMMENT ON COLUMN "payments"."provider_callbacks"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_service_identity_id" on table: "provider_callbacks"
COMMENT ON COLUMN "payments"."provider_callbacks"."created_by_service_identity_id" IS 'Receiving service identity.';
-- Create "provider_outcomes" table
CREATE TABLE "payments"."provider_outcomes" (
  "provider_outcome_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "payment_attempt_id" uuid NOT NULL,
  "provider_session_id" uuid NULL,
  "provider_callback_id" uuid NULL,
  "provider_status_query_id" uuid NULL,
  "payment_rail_id" uuid NOT NULL,
  "provider_transaction_ref" character varying(128) NULL,
  "provider_outcome_status" "payments"."provider_outcome_status_enum" NOT NULL,
  "provider_native_status" character varying(64) NULL,
  "currency_code" character(3) NOT NULL,
  "amount" numeric(18,2) NOT NULL,
  "verified_at" timestamptz NOT NULL,
  "reported_to_central_pms_at" timestamptz NULL,
  "central_pms_report_status" "payments"."central_pms_report_status_enum" NOT NULL,
  "failure_reason_code" character varying(64) NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_provider_outcomes" PRIMARY KEY ("provider_outcome_id")
);
-- Create index "ix_provider_outcomes__correlation_id" to table: "provider_outcomes"
CREATE INDEX "ix_provider_outcomes__correlation_id" ON "payments"."provider_outcomes" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_provider_outcomes__payment_attempt_id" to table: "provider_outcomes"
CREATE INDEX "ix_provider_outcomes__payment_attempt_id" ON "payments"."provider_outcomes" ("payment_attempt_id");
-- Create index "ix_provider_outcomes__payment_rail_id" to table: "provider_outcomes"
CREATE INDEX "ix_provider_outcomes__payment_rail_id" ON "payments"."provider_outcomes" ("payment_rail_id");
-- Create index "ix_provider_outcomes__provider_callback_id" to table: "provider_outcomes"
CREATE INDEX "ix_provider_outcomes__provider_callback_id" ON "payments"."provider_outcomes" ("provider_callback_id");
-- Create index "ix_provider_outcomes__provider_session_id" to table: "provider_outcomes"
CREATE INDEX "ix_provider_outcomes__provider_session_id" ON "payments"."provider_outcomes" ("provider_session_id");
-- Create index "ux_provider_outcomes__provider_callback" to table: "provider_outcomes"
CREATE UNIQUE INDEX "ux_provider_outcomes__provider_callback" ON "payments"."provider_outcomes" ("provider_callback_id") WHERE (provider_callback_id IS NOT NULL);
-- Create index "ux_provider_outcomes__provider_status_query" to table: "provider_outcomes"
CREATE UNIQUE INDEX "ux_provider_outcomes__provider_status_query" ON "payments"."provider_outcomes" ("provider_status_query_id") WHERE (provider_status_query_id IS NOT NULL);
-- Create index "ux_provider_outcomes__provider_transaction_ref" to table: "provider_outcomes"
CREATE UNIQUE INDEX "ux_provider_outcomes__provider_transaction_ref" ON "payments"."provider_outcomes" ("payment_rail_id", "provider_transaction_ref") WHERE (provider_transaction_ref IS NOT NULL);
-- Set comment to table: "provider_outcomes"
COMMENT ON TABLE "payments"."provider_outcomes" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "provider_outcome_id" on table: "provider_outcomes"
COMMENT ON COLUMN "payments"."provider_outcomes"."provider_outcome_id" IS 'Canonical identifier of the provider outcome.';
-- Set comment to column: "payment_attempt_id" on table: "provider_outcomes"
COMMENT ON COLUMN "payments"."provider_outcomes"."payment_attempt_id" IS 'Payment attempt that the outcome relates to.';
-- Set comment to column: "provider_session_id" on table: "provider_outcomes"
COMMENT ON COLUMN "payments"."provider_outcomes"."provider_session_id" IS 'Provider session that produced the outcome.';
-- Set comment to column: "provider_callback_id" on table: "provider_outcomes"
COMMENT ON COLUMN "payments"."provider_outcomes"."provider_callback_id" IS 'Callback that supported the outcome, if applicable.';
-- Set comment to column: "provider_status_query_id" on table: "provider_outcomes"
COMMENT ON COLUMN "payments"."provider_outcomes"."provider_status_query_id" IS 'Status query that supported the outcome, if applicable.';
-- Set comment to column: "payment_rail_id" on table: "provider_outcomes"
COMMENT ON COLUMN "payments"."provider_outcomes"."payment_rail_id" IS 'Payment rail that produced the outcome.';
-- Set comment to column: "provider_transaction_ref" on table: "provider_outcomes"
COMMENT ON COLUMN "payments"."provider_outcomes"."provider_transaction_ref" IS 'Provider transaction reference.';
-- Set comment to column: "provider_outcome_status" on table: "provider_outcomes"
COMMENT ON COLUMN "payments"."provider_outcomes"."provider_outcome_status" IS 'Canonicalized provider-side result.';
-- Set comment to column: "provider_native_status" on table: "provider_outcomes"
COMMENT ON COLUMN "payments"."provider_outcomes"."provider_native_status" IS 'Native provider status value.';
-- Set comment to column: "currency_code" on table: "provider_outcomes"
COMMENT ON COLUMN "payments"."provider_outcomes"."currency_code" IS 'Currency code.';
-- Set comment to column: "amount" on table: "provider_outcomes"
COMMENT ON COLUMN "payments"."provider_outcomes"."amount" IS 'Amount verified from provider evidence.';
-- Set comment to column: "verified_at" on table: "provider_outcomes"
COMMENT ON COLUMN "payments"."provider_outcomes"."verified_at" IS 'Timestamp when evidence was verified.';
-- Set comment to column: "reported_to_central_pms_at" on table: "provider_outcomes"
COMMENT ON COLUMN "payments"."provider_outcomes"."reported_to_central_pms_at" IS 'Timestamp when verified outcome was reported to Central PMS.';
-- Set comment to column: "central_pms_report_status" on table: "provider_outcomes"
COMMENT ON COLUMN "payments"."provider_outcomes"."central_pms_report_status" IS 'Report-to-Central-PMS lifecycle state.';
-- Set comment to column: "failure_reason_code" on table: "provider_outcomes"
COMMENT ON COLUMN "payments"."provider_outcomes"."failure_reason_code" IS 'Controlled failure or rejection reason.';
-- Set comment to column: "correlation_id" on table: "provider_outcomes"
COMMENT ON COLUMN "payments"."provider_outcomes"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "provider_outcomes"
COMMENT ON COLUMN "payments"."provider_outcomes"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_service_identity_id" on table: "provider_outcomes"
COMMENT ON COLUMN "payments"."provider_outcomes"."created_by_service_identity_id" IS 'Service identity that created the outcome.';
-- Set comment to column: "updated_at" on table: "provider_outcomes"
COMMENT ON COLUMN "payments"."provider_outcomes"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_service_identity_id" on table: "provider_outcomes"
COMMENT ON COLUMN "payments"."provider_outcomes"."updated_by_service_identity_id" IS 'Service identity that last updated the record.';
-- Set comment to column: "row_version" on table: "provider_outcomes"
COMMENT ON COLUMN "payments"."provider_outcomes"."row_version" IS 'Optimistic concurrency version.';
-- Create "provider_sessions" table
CREATE TABLE "payments"."provider_sessions" (
  "provider_session_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "payment_attempt_id" uuid NOT NULL,
  "payment_rail_id" uuid NOT NULL,
  "provider_session_ref" character varying(128) NULL,
  "provider_transaction_ref" character varying(128) NULL,
  "idempotency_key" character varying(128) NOT NULL,
  "session_status" "payments"."provider_session_status_enum" NOT NULL,
  "currency_code" character(3) NOT NULL,
  "amount" numeric(18,2) NOT NULL,
  "checkout_url" text NULL,
  "qr_payload" text NULL,
  "expires_at" timestamptz NULL,
  "provider_created_at" timestamptz NULL,
  "provider_expires_at" timestamptz NULL,
  "raw_provider_metadata_ref" character varying(128) NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_provider_sessions" PRIMARY KEY ("provider_session_id")
);
-- Create index "ix_provider_sessions__correlation_id" to table: "provider_sessions"
CREATE INDEX "ix_provider_sessions__correlation_id" ON "payments"."provider_sessions" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_provider_sessions__expires_at" to table: "provider_sessions"
CREATE INDEX "ix_provider_sessions__expires_at" ON "payments"."provider_sessions" ("expires_at");
-- Create index "ix_provider_sessions__payment_attempt_id" to table: "provider_sessions"
CREATE INDEX "ix_provider_sessions__payment_attempt_id" ON "payments"."provider_sessions" ("payment_attempt_id");
-- Create index "ix_provider_sessions__payment_rail_id" to table: "provider_sessions"
CREATE INDEX "ix_provider_sessions__payment_rail_id" ON "payments"."provider_sessions" ("payment_rail_id");
-- Create index "ix_provider_sessions__session_status" to table: "provider_sessions"
CREATE INDEX "ix_provider_sessions__session_status" ON "payments"."provider_sessions" ("session_status");
-- Create index "ux_provider_sessions__active_by_attempt_rail" to table: "provider_sessions"
CREATE UNIQUE INDEX "ux_provider_sessions__active_by_attempt_rail" ON "payments"."provider_sessions" ("payment_attempt_id", "payment_rail_id") WHERE (session_status = ANY (ARRAY['CREATED'::payments.provider_session_status_enum, 'ACTIVE'::payments.provider_session_status_enum, 'PENDING'::payments.provider_session_status_enum]));
-- Create index "ux_provider_sessions__provider_ref" to table: "provider_sessions"
CREATE UNIQUE INDEX "ux_provider_sessions__provider_ref" ON "payments"."provider_sessions" ("payment_rail_id", "provider_session_ref") WHERE (provider_session_ref IS NOT NULL);
-- Set comment to table: "provider_sessions"
COMMENT ON TABLE "payments"."provider_sessions" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "provider_session_id" on table: "provider_sessions"
COMMENT ON COLUMN "payments"."provider_sessions"."provider_session_id" IS 'Canonical identifier of the provider session.';
-- Set comment to column: "payment_attempt_id" on table: "provider_sessions"
COMMENT ON COLUMN "payments"."provider_sessions"."payment_attempt_id" IS 'Target payment attempt.';
-- Set comment to column: "payment_rail_id" on table: "provider_sessions"
COMMENT ON COLUMN "payments"."provider_sessions"."payment_rail_id" IS 'Payment rail used for provider execution.';
-- Set comment to column: "provider_session_ref" on table: "provider_sessions"
COMMENT ON COLUMN "payments"."provider_sessions"."provider_session_ref" IS 'Provider-side session, checkout, intent, or order reference.';
-- Set comment to column: "provider_transaction_ref" on table: "provider_sessions"
COMMENT ON COLUMN "payments"."provider_sessions"."provider_transaction_ref" IS 'Provider transaction reference where known at session creation.';
-- Set comment to column: "idempotency_key" on table: "provider_sessions"
COMMENT ON COLUMN "payments"."provider_sessions"."idempotency_key" IS 'Idempotency key for provider-session creation.';
-- Set comment to column: "session_status" on table: "provider_sessions"
COMMENT ON COLUMN "payments"."provider_sessions"."session_status" IS 'Provider session lifecycle state.';
-- Set comment to column: "currency_code" on table: "provider_sessions"
COMMENT ON COLUMN "payments"."provider_sessions"."currency_code" IS 'Currency code.';
-- Set comment to column: "amount" on table: "provider_sessions"
COMMENT ON COLUMN "payments"."provider_sessions"."amount" IS 'Amount submitted to provider.';
-- Set comment to column: "checkout_url" on table: "provider_sessions"
COMMENT ON COLUMN "payments"."provider_sessions"."checkout_url" IS 'Hosted checkout URL where applicable.';
-- Set comment to column: "qr_payload" on table: "provider_sessions"
COMMENT ON COLUMN "payments"."provider_sessions"."qr_payload" IS 'QR or QRPh payload where applicable.';
-- Set comment to column: "expires_at" on table: "provider_sessions"
COMMENT ON COLUMN "payments"."provider_sessions"."expires_at" IS 'Provider session expiry timestamp.';
-- Set comment to column: "provider_created_at" on table: "provider_sessions"
COMMENT ON COLUMN "payments"."provider_sessions"."provider_created_at" IS 'Provider-side creation timestamp where known.';
-- Set comment to column: "provider_expires_at" on table: "provider_sessions"
COMMENT ON COLUMN "payments"."provider_sessions"."provider_expires_at" IS 'Provider-side expiry timestamp where known.';
-- Set comment to column: "raw_provider_metadata_ref" on table: "provider_sessions"
COMMENT ON COLUMN "payments"."provider_sessions"."raw_provider_metadata_ref" IS 'Reference to stored provider metadata if retained separately.';
-- Set comment to column: "correlation_id" on table: "provider_sessions"
COMMENT ON COLUMN "payments"."provider_sessions"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "provider_sessions"
COMMENT ON COLUMN "payments"."provider_sessions"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_service_identity_id" on table: "provider_sessions"
COMMENT ON COLUMN "payments"."provider_sessions"."created_by_service_identity_id" IS 'Service identity that created the provider session.';
-- Set comment to column: "updated_at" on table: "provider_sessions"
COMMENT ON COLUMN "payments"."provider_sessions"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_service_identity_id" on table: "provider_sessions"
COMMENT ON COLUMN "payments"."provider_sessions"."updated_by_service_identity_id" IS 'Service identity that last updated the provider session.';
-- Set comment to column: "row_version" on table: "provider_sessions"
COMMENT ON COLUMN "payments"."provider_sessions"."row_version" IS 'Optimistic concurrency version.';
-- Create "provider_status_queries" table
CREATE TABLE "payments"."provider_status_queries" (
  "provider_status_query_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "payment_attempt_id" uuid NOT NULL,
  "provider_session_id" uuid NULL,
  "payment_rail_id" uuid NOT NULL,
  "provider_transaction_ref" character varying(128) NULL,
  "query_status" "payments"."provider_status_query_status_enum" NOT NULL,
  "provider_result_status" character varying(64) NULL,
  "http_status_code" integer NULL,
  "request_hash" character(64) NULL,
  "response_hash" character(64) NULL,
  "response_storage_ref" character varying(256) NULL,
  "failure_reason_code" character varying(64) NULL,
  "requested_at" timestamptz NOT NULL,
  "completed_at" timestamptz NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  CONSTRAINT "pk_provider_status_queries" PRIMARY KEY ("provider_status_query_id")
);
-- Create index "ix_provider_status_queries__correlation_id" to table: "provider_status_queries"
CREATE INDEX "ix_provider_status_queries__correlation_id" ON "payments"."provider_status_queries" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_provider_status_queries__payment_attempt_id" to table: "provider_status_queries"
CREATE INDEX "ix_provider_status_queries__payment_attempt_id" ON "payments"."provider_status_queries" ("payment_attempt_id");
-- Create index "ix_provider_status_queries__payment_rail_id" to table: "provider_status_queries"
CREATE INDEX "ix_provider_status_queries__payment_rail_id" ON "payments"."provider_status_queries" ("payment_rail_id");
-- Create index "ix_provider_status_queries__provider_session_id" to table: "provider_status_queries"
CREATE INDEX "ix_provider_status_queries__provider_session_id" ON "payments"."provider_status_queries" ("provider_session_id");
-- Create index "ix_provider_status_queries__query_status" to table: "provider_status_queries"
CREATE INDEX "ix_provider_status_queries__query_status" ON "payments"."provider_status_queries" ("query_status");
-- Set comment to table: "provider_status_queries"
COMMENT ON TABLE "payments"."provider_status_queries" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "provider_status_query_id" on table: "provider_status_queries"
COMMENT ON COLUMN "payments"."provider_status_queries"."provider_status_query_id" IS 'Canonical identifier of the provider status query.';
-- Set comment to column: "payment_attempt_id" on table: "provider_status_queries"
COMMENT ON COLUMN "payments"."provider_status_queries"."payment_attempt_id" IS 'Payment attempt being investigated or verified.';
-- Set comment to column: "provider_session_id" on table: "provider_status_queries"
COMMENT ON COLUMN "payments"."provider_status_queries"."provider_session_id" IS 'Provider session being queried.';
-- Set comment to column: "payment_rail_id" on table: "provider_status_queries"
COMMENT ON COLUMN "payments"."provider_status_queries"."payment_rail_id" IS 'Payment rail queried.';
-- Set comment to column: "provider_transaction_ref" on table: "provider_status_queries"
COMMENT ON COLUMN "payments"."provider_status_queries"."provider_transaction_ref" IS 'Provider transaction reference used for query.';
-- Set comment to column: "query_status" on table: "provider_status_queries"
COMMENT ON COLUMN "payments"."provider_status_queries"."query_status" IS 'Query lifecycle state.';
-- Set comment to column: "provider_result_status" on table: "provider_status_queries"
COMMENT ON COLUMN "payments"."provider_status_queries"."provider_result_status" IS 'Raw or provider-normalized result status.';
-- Set comment to column: "http_status_code" on table: "provider_status_queries"
COMMENT ON COLUMN "payments"."provider_status_queries"."http_status_code" IS 'HTTP status returned by provider.';
-- Set comment to column: "request_hash" on table: "provider_status_queries"
COMMENT ON COLUMN "payments"."provider_status_queries"."request_hash" IS 'Hash of request payload or request signature basis.';
-- Set comment to column: "response_hash" on table: "provider_status_queries"
COMMENT ON COLUMN "payments"."provider_status_queries"."response_hash" IS 'Hash of provider response payload where retained.';
-- Set comment to column: "response_storage_ref" on table: "provider_status_queries"
COMMENT ON COLUMN "payments"."provider_status_queries"."response_storage_ref" IS 'Reference to response payload if stored externally.';
-- Set comment to column: "failure_reason_code" on table: "provider_status_queries"
COMMENT ON COLUMN "payments"."provider_status_queries"."failure_reason_code" IS 'Controlled failure reason.';
-- Set comment to column: "requested_at" on table: "provider_status_queries"
COMMENT ON COLUMN "payments"."provider_status_queries"."requested_at" IS 'Query request timestamp.';
-- Set comment to column: "completed_at" on table: "provider_status_queries"
COMMENT ON COLUMN "payments"."provider_status_queries"."completed_at" IS 'Query completion timestamp.';
-- Set comment to column: "correlation_id" on table: "provider_status_queries"
COMMENT ON COLUMN "payments"."provider_status_queries"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "provider_status_queries"
COMMENT ON COLUMN "payments"."provider_status_queries"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_service_identity_id" on table: "provider_status_queries"
COMMENT ON COLUMN "payments"."provider_status_queries"."created_by_service_identity_id" IS 'Querying service identity.';
-- Create enum type "mops_transaction_record_status_enum"
CREATE TYPE "reconciliation"."mops_transaction_record_status_enum" AS ENUM ('RECORDED', 'IMPORTED', 'PENDING_RECONCILIATION', 'RECONCILED', 'DISPUTED', 'REJECTED', 'CANCELLED');
-- Create enum type "reconciliation_comparison_basis_enum"
CREATE TYPE "reconciliation"."reconciliation_comparison_basis_enum" AS ENUM ('MOPS_TO_CORE', 'MOPS_TO_SETTLEMENT', 'PROVIDER_TO_CORE', 'MANUAL_GATE_TO_CORE', 'COUPON_WALLET_TO_APPLICATION', 'SETTLEMENT_TO_CONFIRMATION', 'INCIDENT_SCOPE_REVIEW');
-- Create enum type "reconciliation_exception_severity_enum"
CREATE TYPE "reconciliation"."reconciliation_exception_severity_enum" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL');
-- Create enum type "reconciliation_exception_status_enum"
CREATE TYPE "reconciliation"."reconciliation_exception_status_enum" AS ENUM ('OPEN', 'ASSIGNED', 'UNDER_REVIEW', 'RESOLVED', 'REJECTED', 'ESCALATED', 'CLOSED', 'CANCELLED');
-- Create enum type "reconciliation_exception_type_enum"
CREATE TYPE "reconciliation"."reconciliation_exception_type_enum" AS ENUM ('AMOUNT_MISMATCH', 'MISSING_PAYMENT_CONFIRMATION', 'MISSING_PROVIDER_OUTCOME', 'MISSING_MOPS_RECORD', 'DUPLICATE_RECORD', 'MANUAL_GATE_WITHOUT_PAYMENT', 'SETTLEMENT_MISMATCH', 'COUPON_WALLET_MISMATCH', 'UNRESOLVED_CONTINUITY_RECORD', 'POLICY_EXCEPTION', 'UNKNOWN_EXCEPTION');
-- Create enum type "reconciliation_item_status_enum"
CREATE TYPE "reconciliation"."reconciliation_item_status_enum" AS ENUM ('PENDING', 'MATCHED', 'MISMATCHED', 'EXCEPTION', 'DISPUTED', 'REJECTED', 'RESOLVED', 'CLOSED');
-- Create enum type "reconciliation_match_status_enum"
CREATE TYPE "reconciliation"."reconciliation_match_status_enum" AS ENUM ('NOT_EVALUATED', 'MATCH', 'AMOUNT_MISMATCH', 'MISSING_SOURCE', 'MISSING_TARGET', 'DUPLICATE', 'INCONCLUSIVE', 'REJECTED');
-- Create enum type "reconciliation_run_status_enum"
CREATE TYPE "reconciliation"."reconciliation_run_status_enum" AS ENUM ('STARTED', 'PROCESSING', 'COMPLETED', 'FAILED', 'CANCELLED', 'REPROCESSING');
-- Create enum type "reconciliation_run_type_enum"
CREATE TYPE "reconciliation"."reconciliation_run_type_enum" AS ENUM ('MOPS_RECONCILIATION', 'PROVIDER_SETTLEMENT', 'MANUAL_GATE_REVIEW', 'INCIDENT_RECONCILIATION', 'COUPON_WALLET_RECONCILIATION', 'PAYMENT_PROVIDER_RECONCILIATION', 'VENDOR_PMS_RECONCILIATION');
-- Create enum type "reconciliation_scope_type_enum"
CREATE TYPE "reconciliation"."reconciliation_scope_type_enum" AS ENUM ('TIME_WINDOW', 'SITE', 'SITE_GROUP', 'INCIDENT', 'SOURCE_BATCH', 'PAYMENT_RAIL', 'VENDOR_SYSTEM', 'MIXED');
-- Create enum type "settlement_comparison_result_enum"
CREATE TYPE "reconciliation"."settlement_comparison_result_enum" AS ENUM ('MATCHED', 'MISMATCHED', 'SHORT_SETTLED', 'OVER_SETTLED', 'MISSING_SETTLEMENT', 'DUPLICATE_SETTLEMENT', 'UNRESOLVED', 'REJECTED');
-- Create enum type "settlement_comparison_source_type_enum"
CREATE TYPE "reconciliation"."settlement_comparison_source_type_enum" AS ENUM ('PROVIDER_SETTLEMENT_REPORT', 'BANK_STATEMENT', 'PAYMENT_RAIL_REPORT', 'MERCHANT_WALLET_LEDGER', 'MOPS_EXPORT', 'MANUAL_COLLECTION_REPORT', 'OTHER');
-- Create "import_mops_transaction_record" function
CREATE FUNCTION "reconciliation"."import_mops_transaction_record" () RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'reconciliation.import_mops_transaction_record is a v1.2 routine placeholder and must be implemented before production use'; END; $$;
-- Create "resolve_reconciliation_item" function
CREATE FUNCTION "reconciliation"."resolve_reconciliation_item" () RETURNS void LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'reconciliation.resolve_reconciliation_item is a v1.2 routine placeholder and must be implemented before production use'; END; $$;
-- Create "mops_transaction_records" table
CREATE TABLE "reconciliation"."mops_transaction_records" (
  "mops_transaction_record_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "parking_session_id" uuid NULL,
  "manual_gate_log_id" uuid NULL,
  "incident_record_id" uuid NULL,
  "site_id" uuid NOT NULL,
  "lane_id" uuid NULL,
  "source_system_code" character varying(64) NOT NULL,
  "source_transaction_ref" character varying(128) NULL,
  "source_batch_ref" character varying(128) NULL,
  "collection_reference" character varying(128) NULL,
  "currency_code" character(3) NULL,
  "amount" numeric(18,2) NULL,
  "payment_method_label" character varying(64) NULL,
  "continuity_reason_code" character varying(64) NOT NULL,
  "record_status" "reconciliation"."mops_transaction_record_status_enum" NOT NULL,
  "captured_at" timestamptz NOT NULL,
  "imported_at" timestamptz NULL,
  "reconciled_at" timestamptz NULL,
  "rejected_at" timestamptz NULL,
  "disputed_at" timestamptz NULL,
  "failure_reason_code" character varying(64) NULL,
  "evidence_ref" character varying(256) NULL,
  "evidence_hash" character(64) NULL,
  "captured_by_user_id" uuid NULL,
  "captured_by_service_identity_id" uuid NULL,
  "imported_by_service_identity_id" uuid NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_mops_transaction_records" PRIMARY KEY ("mops_transaction_record_id")
);
-- Create index "ix_mops_transaction_records__correlation_id" to table: "mops_transaction_records"
CREATE INDEX "ix_mops_transaction_records__correlation_id" ON "reconciliation"."mops_transaction_records" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_mops_transaction_records__imported_by_service_identity_id" to table: "mops_transaction_records"
CREATE INDEX "ix_mops_transaction_records__imported_by_service_identity_id" ON "reconciliation"."mops_transaction_records" ("imported_by_service_identity_id");
-- Create index "ix_mops_transaction_records__incident_record_id" to table: "mops_transaction_records"
CREATE INDEX "ix_mops_transaction_records__incident_record_id" ON "reconciliation"."mops_transaction_records" ("incident_record_id");
-- Create index "ix_mops_transaction_records__lane_id" to table: "mops_transaction_records"
CREATE INDEX "ix_mops_transaction_records__lane_id" ON "reconciliation"."mops_transaction_records" ("lane_id");
-- Create index "ix_mops_transaction_records__manual_gate_log_id" to table: "mops_transaction_records"
CREATE INDEX "ix_mops_transaction_records__manual_gate_log_id" ON "reconciliation"."mops_transaction_records" ("manual_gate_log_id");
-- Create index "ix_mops_transaction_records__parking_session_id" to table: "mops_transaction_records"
CREATE INDEX "ix_mops_transaction_records__parking_session_id" ON "reconciliation"."mops_transaction_records" ("parking_session_id");
-- Create index "ix_mops_transaction_records__site_id" to table: "mops_transaction_records"
CREATE INDEX "ix_mops_transaction_records__site_id" ON "reconciliation"."mops_transaction_records" ("site_id");
-- Create index "ux_mops_transaction_records__source_batch_collection" to table: "mops_transaction_records"
CREATE UNIQUE INDEX "ux_mops_transaction_records__source_batch_collection" ON "reconciliation"."mops_transaction_records" ("source_system_code", "source_batch_ref", "collection_reference") WHERE ((source_batch_ref IS NOT NULL) AND (collection_reference IS NOT NULL));
-- Create index "ux_mops_transaction_records__source_transaction_ref" to table: "mops_transaction_records"
CREATE UNIQUE INDEX "ux_mops_transaction_records__source_transaction_ref" ON "reconciliation"."mops_transaction_records" ("source_system_code", "source_transaction_ref") WHERE (source_transaction_ref IS NOT NULL);
-- Set comment to table: "mops_transaction_records"
COMMENT ON TABLE "reconciliation"."mops_transaction_records" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "mops_transaction_record_id" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."mops_transaction_record_id" IS 'Canonical identifier of the MoPS or continuity-origin record.';
-- Set comment to column: "parking_session_id" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."parking_session_id" IS 'Related parking session, where identifiable.';
-- Set comment to column: "manual_gate_log_id" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."manual_gate_log_id" IS 'Related manual gate action, where applicable.';
-- Set comment to column: "incident_record_id" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."incident_record_id" IS 'Incident or continuity event that caused the record.';
-- Set comment to column: "site_id" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."site_id" IS 'Site where the continuity event occurred.';
-- Set comment to column: "lane_id" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."lane_id" IS 'Lane where the continuity event occurred.';
-- Set comment to column: "source_system_code" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."source_system_code" IS 'Source system or continuity tool code.';
-- Set comment to column: "source_transaction_ref" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."source_transaction_ref" IS 'Source transaction reference.';
-- Set comment to column: "source_batch_ref" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."source_batch_ref" IS 'Import batch or source batch reference.';
-- Set comment to column: "collection_reference" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."collection_reference" IS 'Manual or continuity collection reference.';
-- Set comment to column: "currency_code" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."currency_code" IS 'Currency code for amount fields.';
-- Set comment to column: "amount" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."amount" IS 'Amount captured in continuity path.';
-- Set comment to column: "payment_method_label" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."payment_method_label" IS 'Continuity-recorded payment method label.';
-- Set comment to column: "continuity_reason_code" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."continuity_reason_code" IS 'Controlled reason for continuity handling.';
-- Set comment to column: "record_status" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."record_status" IS 'Lifecycle state of the continuity-origin record.';
-- Set comment to column: "captured_at" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."captured_at" IS 'Timestamp when continuity event was captured.';
-- Set comment to column: "imported_at" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."imported_at" IS 'Timestamp when record was imported into Central PMS.';
-- Set comment to column: "reconciled_at" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."reconciled_at" IS 'Timestamp when record reached reconciled state.';
-- Set comment to column: "rejected_at" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."rejected_at" IS 'Timestamp when record was rejected.';
-- Set comment to column: "disputed_at" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."disputed_at" IS 'Timestamp when record was disputed.';
-- Set comment to column: "failure_reason_code" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."failure_reason_code" IS 'Controlled failure or rejection reason.';
-- Set comment to column: "evidence_ref" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."evidence_ref" IS 'Reference to supporting evidence or import file.';
-- Set comment to column: "evidence_hash" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."evidence_hash" IS 'Hash of supporting evidence where applicable.';
-- Set comment to column: "captured_by_user_id" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."captured_by_user_id" IS 'Human actor who captured the record.';
-- Set comment to column: "captured_by_service_identity_id" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."captured_by_service_identity_id" IS 'Service or tool identity that captured the record.';
-- Set comment to column: "imported_by_service_identity_id" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."imported_by_service_identity_id" IS 'Service identity that imported the record.';
-- Set comment to column: "correlation_id" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."created_by_user_id" IS 'User who created the record.';
-- Set comment to column: "created_by_service_identity_id" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."created_by_service_identity_id" IS 'Service identity that created the record.';
-- Set comment to column: "updated_at" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."updated_by_user_id" IS 'User who last updated the record.';
-- Set comment to column: "updated_by_service_identity_id" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."updated_by_service_identity_id" IS 'Service identity that last updated the record.';
-- Set comment to column: "row_version" on table: "mops_transaction_records"
COMMENT ON COLUMN "reconciliation"."mops_transaction_records"."row_version" IS 'Optimistic concurrency version.';
-- Create "reconciliation_exceptions" table
CREATE TABLE "reconciliation"."reconciliation_exceptions" (
  "reconciliation_exception_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "reconciliation_run_id" uuid NOT NULL,
  "reconciliation_item_id" uuid NULL,
  "incident_record_id" uuid NULL,
  "exception_type" "reconciliation"."reconciliation_exception_type_enum" NOT NULL,
  "exception_severity" "reconciliation"."reconciliation_exception_severity_enum" NOT NULL,
  "exception_status" "reconciliation"."reconciliation_exception_status_enum" NOT NULL,
  "exception_reason_code" character varying(64) NOT NULL,
  "exception_summary" character varying(256) NOT NULL,
  "exception_detail" text NULL,
  "assigned_to_user_id" uuid NULL,
  "assigned_to_service_identity_id" uuid NULL,
  "created_from_status" character varying(64) NULL,
  "detected_at" timestamptz NOT NULL,
  "assigned_at" timestamptz NULL DEFAULT now(),
  "resolved_at" timestamptz NULL,
  "closed_at" timestamptz NULL,
  "resolution_reason_code" character varying(64) NULL,
  "closure_reason_code" character varying(64) NULL,
  "resolved_by_user_id" uuid NULL,
  "resolved_by_service_identity_id" uuid NULL,
  "closed_by_user_id" uuid NULL,
  "closed_by_service_identity_id" uuid NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_reconciliation_exceptions" PRIMARY KEY ("reconciliation_exception_id")
);
-- Create index "ix_reconciliation_exceptions__assigned_to_user_id" to table: "reconciliation_exceptions"
CREATE INDEX "ix_reconciliation_exceptions__assigned_to_user_id" ON "reconciliation"."reconciliation_exceptions" ("assigned_to_user_id");
-- Create index "ix_reconciliation_exceptions__correlation_id" to table: "reconciliation_exceptions"
CREATE INDEX "ix_reconciliation_exceptions__correlation_id" ON "reconciliation"."reconciliation_exceptions" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_reconciliation_exceptions__incident_record_id" to table: "reconciliation_exceptions"
CREATE INDEX "ix_reconciliation_exceptions__incident_record_id" ON "reconciliation"."reconciliation_exceptions" ("incident_record_id");
-- Create index "ix_reconciliation_exceptions__reconciliation_item_id" to table: "reconciliation_exceptions"
CREATE INDEX "ix_reconciliation_exceptions__reconciliation_item_id" ON "reconciliation"."reconciliation_exceptions" ("reconciliation_item_id");
-- Create index "ix_reconciliation_exceptions__reconciliation_run_id" to table: "reconciliation_exceptions"
CREATE INDEX "ix_reconciliation_exceptions__reconciliation_run_id" ON "reconciliation"."reconciliation_exceptions" ("reconciliation_run_id");
-- Set comment to table: "reconciliation_exceptions"
COMMENT ON TABLE "reconciliation"."reconciliation_exceptions" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "reconciliation_exception_id" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."reconciliation_exception_id" IS 'Canonical identifier of the reconciliation exception.';
-- Set comment to column: "reconciliation_run_id" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."reconciliation_run_id" IS 'Run where the exception was discovered.';
-- Set comment to column: "reconciliation_item_id" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."reconciliation_item_id" IS 'Item that produced the exception.';
-- Set comment to column: "incident_record_id" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."incident_record_id" IS 'Related incident, where applicable.';
-- Set comment to column: "exception_type" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."exception_type" IS 'Type of reconciliation exception.';
-- Set comment to column: "exception_severity" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."exception_severity" IS 'Severity of exception.';
-- Set comment to column: "exception_status" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."exception_status" IS 'Exception lifecycle state.';
-- Set comment to column: "exception_reason_code" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."exception_reason_code" IS 'Controlled reason for exception.';
-- Set comment to column: "exception_summary" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."exception_summary" IS 'Short human-readable summary.';
-- Set comment to column: "exception_detail" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."exception_detail" IS 'Controlled detailed note. Must not store sensitive evidence casually.';
-- Set comment to column: "assigned_to_user_id" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."assigned_to_user_id" IS 'User assigned to resolve the exception.';
-- Set comment to column: "assigned_to_service_identity_id" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."assigned_to_service_identity_id" IS 'Service identity assigned to resolve the exception.';
-- Set comment to column: "created_from_status" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."created_from_status" IS 'Item or source status that triggered the exception.';
-- Set comment to column: "detected_at" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."detected_at" IS 'Timestamp when exception was detected.';
-- Set comment to column: "assigned_at" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."assigned_at" IS 'Timestamp when exception was assigned.';
-- Set comment to column: "resolved_at" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."resolved_at" IS 'Timestamp when exception was resolved.';
-- Set comment to column: "closed_at" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."closed_at" IS 'Timestamp when exception was closed.';
-- Set comment to column: "resolution_reason_code" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."resolution_reason_code" IS 'Controlled resolution reason.';
-- Set comment to column: "closure_reason_code" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."closure_reason_code" IS 'Controlled closure reason.';
-- Set comment to column: "resolved_by_user_id" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."resolved_by_user_id" IS 'User who resolved the exception.';
-- Set comment to column: "resolved_by_service_identity_id" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."resolved_by_service_identity_id" IS 'Service identity that resolved the exception.';
-- Set comment to column: "closed_by_user_id" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."closed_by_user_id" IS 'User who closed the exception.';
-- Set comment to column: "closed_by_service_identity_id" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."closed_by_service_identity_id" IS 'Service identity that closed the exception.';
-- Set comment to column: "correlation_id" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."created_by_user_id" IS 'User who created the exception.';
-- Set comment to column: "created_by_service_identity_id" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."created_by_service_identity_id" IS 'Service identity that created the exception.';
-- Set comment to column: "updated_at" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."updated_by_user_id" IS 'User who last updated the exception.';
-- Set comment to column: "updated_by_service_identity_id" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."updated_by_service_identity_id" IS 'Service identity that last updated the exception.';
-- Set comment to column: "row_version" on table: "reconciliation_exceptions"
COMMENT ON COLUMN "reconciliation"."reconciliation_exceptions"."row_version" IS 'Optimistic concurrency version.';
-- Create "reconciliation_items" table
CREATE TABLE "reconciliation"."reconciliation_items" (
  "reconciliation_item_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "reconciliation_run_id" uuid NOT NULL,
  "mops_transaction_record_id" uuid NULL,
  "manual_gate_log_id" uuid NULL,
  "payment_attempt_id" uuid NULL,
  "payment_confirmation_id" uuid NULL,
  "provider_outcome_id" uuid NULL,
  "target_entity_type" character varying(64) NULL,
  "target_entity_id" uuid NULL,
  "comparison_basis" "reconciliation"."reconciliation_comparison_basis_enum" NOT NULL,
  "item_status" "reconciliation"."reconciliation_item_status_enum" NOT NULL,
  "match_status" "reconciliation"."reconciliation_match_status_enum" NOT NULL,
  "expected_amount" numeric(18,2) NULL,
  "actual_amount" numeric(18,2) NULL,
  "currency_code" character(3) NULL,
  "variance_amount" numeric(18,2) NULL,
  "exception_reason_code" character varying(64) NULL,
  "resolved_at" timestamptz NULL,
  "resolved_by_user_id" uuid NULL,
  "resolved_by_service_identity_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "correlation_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_reconciliation_items" PRIMARY KEY ("reconciliation_item_id")
);
-- Create index "ix_reconciliation_items__correlation_id" to table: "reconciliation_items"
CREATE INDEX "ix_reconciliation_items__correlation_id" ON "reconciliation"."reconciliation_items" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_reconciliation_items__manual_gate_log_id" to table: "reconciliation_items"
CREATE INDEX "ix_reconciliation_items__manual_gate_log_id" ON "reconciliation"."reconciliation_items" ("manual_gate_log_id");
-- Create index "ix_reconciliation_items__mops_transaction_record_id" to table: "reconciliation_items"
CREATE INDEX "ix_reconciliation_items__mops_transaction_record_id" ON "reconciliation"."reconciliation_items" ("mops_transaction_record_id");
-- Create index "ix_reconciliation_items__payment_attempt_id" to table: "reconciliation_items"
CREATE INDEX "ix_reconciliation_items__payment_attempt_id" ON "reconciliation"."reconciliation_items" ("payment_attempt_id");
-- Create index "ix_reconciliation_items__payment_confirmation_id" to table: "reconciliation_items"
CREATE INDEX "ix_reconciliation_items__payment_confirmation_id" ON "reconciliation"."reconciliation_items" ("payment_confirmation_id");
-- Create index "ix_reconciliation_items__provider_outcome_id" to table: "reconciliation_items"
CREATE INDEX "ix_reconciliation_items__provider_outcome_id" ON "reconciliation"."reconciliation_items" ("provider_outcome_id");
-- Create index "ix_reconciliation_items__reconciliation_run_id" to table: "reconciliation_items"
CREATE INDEX "ix_reconciliation_items__reconciliation_run_id" ON "reconciliation"."reconciliation_items" ("reconciliation_run_id");
-- Set comment to table: "reconciliation_items"
COMMENT ON TABLE "reconciliation"."reconciliation_items" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "reconciliation_item_id" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."reconciliation_item_id" IS 'Canonical identifier of the reconciliation item.';
-- Set comment to column: "reconciliation_run_id" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."reconciliation_run_id" IS 'Parent reconciliation run.';
-- Set comment to column: "mops_transaction_record_id" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."mops_transaction_record_id" IS 'MoPS or continuity-origin record being reconciled.';
-- Set comment to column: "manual_gate_log_id" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."manual_gate_log_id" IS 'Manual gate log being reconciled, where applicable.';
-- Set comment to column: "payment_attempt_id" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."payment_attempt_id" IS 'Related payment attempt, where applicable.';
-- Set comment to column: "payment_confirmation_id" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."payment_confirmation_id" IS 'Related payment confirmation, where applicable.';
-- Set comment to column: "provider_outcome_id" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."provider_outcome_id" IS 'Related provider outcome, where applicable.';
-- Set comment to column: "target_entity_type" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."target_entity_type" IS 'Generic target entity type where a specific FK is not available.';
-- Set comment to column: "target_entity_id" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."target_entity_id" IS 'Generic target entity ID where a specific FK is not available.';
-- Set comment to column: "comparison_basis" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."comparison_basis" IS 'Basis used for comparison.';
-- Set comment to column: "item_status" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."item_status" IS 'Item-level reconciliation outcome.';
-- Set comment to column: "match_status" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."match_status" IS 'Match classification.';
-- Set comment to column: "expected_amount" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."expected_amount" IS 'Expected amount, where applicable.';
-- Set comment to column: "actual_amount" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."actual_amount" IS 'Actual amount from compared evidence.';
-- Set comment to column: "currency_code" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."currency_code" IS 'Currency code for amount comparison.';
-- Set comment to column: "variance_amount" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."variance_amount" IS 'Difference between expected and actual amount.';
-- Set comment to column: "exception_reason_code" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."exception_reason_code" IS 'Controlled exception reason.';
-- Set comment to column: "resolved_at" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."resolved_at" IS 'Timestamp when item was resolved.';
-- Set comment to column: "resolved_by_user_id" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."resolved_by_user_id" IS 'User who resolved the item.';
-- Set comment to column: "resolved_by_service_identity_id" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."resolved_by_service_identity_id" IS 'Service identity that resolved the item.';
-- Set comment to column: "created_at" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."created_by_user_id" IS 'User who created the item.';
-- Set comment to column: "created_by_service_identity_id" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."created_by_service_identity_id" IS 'Service identity that created the item.';
-- Set comment to column: "updated_at" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."updated_by_user_id" IS 'User who last updated the item.';
-- Set comment to column: "updated_by_service_identity_id" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."updated_by_service_identity_id" IS 'Service identity that last updated the item.';
-- Set comment to column: "correlation_id" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "row_version" on table: "reconciliation_items"
COMMENT ON COLUMN "reconciliation"."reconciliation_items"."row_version" IS 'Optimistic concurrency version.';
-- Create "reconciliation_runs" table
CREATE TABLE "reconciliation"."reconciliation_runs" (
  "reconciliation_run_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "run_code" character varying(64) NOT NULL,
  "run_type" "reconciliation"."reconciliation_run_type_enum" NOT NULL,
  "run_status" "reconciliation"."reconciliation_run_status_enum" NOT NULL,
  "scope_type" "reconciliation"."reconciliation_scope_type_enum" NOT NULL,
  "site_group_id" uuid NULL,
  "site_id" uuid NULL,
  "incident_record_id" uuid NULL,
  "payment_rail_id" uuid NULL,
  "vendor_system_id" uuid NULL,
  "source_batch_ref" character varying(128) NULL,
  "window_start_at" timestamptz NULL,
  "window_end_at" timestamptz NULL,
  "started_at" timestamptz NOT NULL DEFAULT now(),
  "completed_at" timestamptz NULL,
  "failed_at" timestamptz NULL,
  "failure_reason_code" character varying(64) NULL,
  "item_count" integer NOT NULL,
  "matched_count" integer NOT NULL,
  "exception_count" integer NOT NULL,
  "rejected_count" integer NOT NULL,
  "disputed_count" integer NOT NULL,
  "initiated_by_user_id" uuid NULL,
  "initiated_by_service_identity_id" uuid NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_reconciliation_runs" PRIMARY KEY ("reconciliation_run_id")
);
-- Create index "ix_reconciliation_runs__correlation_id" to table: "reconciliation_runs"
CREATE INDEX "ix_reconciliation_runs__correlation_id" ON "reconciliation"."reconciliation_runs" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_reconciliation_runs__incident_record_id" to table: "reconciliation_runs"
CREATE INDEX "ix_reconciliation_runs__incident_record_id" ON "reconciliation"."reconciliation_runs" ("incident_record_id");
-- Create index "ix_reconciliation_runs__payment_rail_id" to table: "reconciliation_runs"
CREATE INDEX "ix_reconciliation_runs__payment_rail_id" ON "reconciliation"."reconciliation_runs" ("payment_rail_id");
-- Create index "ix_reconciliation_runs__site_group_id" to table: "reconciliation_runs"
CREATE INDEX "ix_reconciliation_runs__site_group_id" ON "reconciliation"."reconciliation_runs" ("site_group_id");
-- Create index "ix_reconciliation_runs__site_id" to table: "reconciliation_runs"
CREATE INDEX "ix_reconciliation_runs__site_id" ON "reconciliation"."reconciliation_runs" ("site_id");
-- Set comment to table: "reconciliation_runs"
COMMENT ON TABLE "reconciliation"."reconciliation_runs" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "reconciliation_run_id" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."reconciliation_run_id" IS 'Canonical identifier of the reconciliation run.';
-- Set comment to column: "run_code" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."run_code" IS 'Human-readable or generated run code.';
-- Set comment to column: "run_type" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."run_type" IS 'Type of reconciliation run.';
-- Set comment to column: "run_status" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."run_status" IS 'Run lifecycle state.';
-- Set comment to column: "scope_type" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."scope_type" IS 'Scope type for the run.';
-- Set comment to column: "site_group_id" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."site_group_id" IS 'Site group scope.';
-- Set comment to column: "site_id" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."site_id" IS 'Site scope.';
-- Set comment to column: "incident_record_id" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."incident_record_id" IS 'Incident being reconciled, where applicable.';
-- Set comment to column: "payment_rail_id" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."payment_rail_id" IS 'Payment rail scope, where applicable.';
-- Set comment to column: "vendor_system_id" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."vendor_system_id" IS 'Vendor system scope, where applicable.';
-- Set comment to column: "source_batch_ref" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."source_batch_ref" IS 'Source batch reference being reconciled.';
-- Set comment to column: "window_start_at" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."window_start_at" IS 'Reconciliation window start.';
-- Set comment to column: "window_end_at" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."window_end_at" IS 'Reconciliation window end.';
-- Set comment to column: "started_at" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."started_at" IS 'Run start timestamp.';
-- Set comment to column: "completed_at" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."completed_at" IS 'Run completion timestamp.';
-- Set comment to column: "failed_at" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."failed_at" IS 'Run failure timestamp.';
-- Set comment to column: "failure_reason_code" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."failure_reason_code" IS 'Controlled failure reason.';
-- Set comment to column: "item_count" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."item_count" IS 'Total item count.';
-- Set comment to column: "matched_count" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."matched_count" IS 'Matched item count.';
-- Set comment to column: "exception_count" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."exception_count" IS 'Exception item count.';
-- Set comment to column: "rejected_count" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."rejected_count" IS 'Rejected item count.';
-- Set comment to column: "disputed_count" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."disputed_count" IS 'Disputed item count.';
-- Set comment to column: "initiated_by_user_id" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."initiated_by_user_id" IS 'User who initiated the run.';
-- Set comment to column: "initiated_by_service_identity_id" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."initiated_by_service_identity_id" IS 'Service identity that initiated the run.';
-- Set comment to column: "correlation_id" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."created_by_user_id" IS 'User who created the run record.';
-- Set comment to column: "created_by_service_identity_id" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."created_by_service_identity_id" IS 'Service identity that created the run record.';
-- Set comment to column: "updated_at" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."updated_by_user_id" IS 'User who last updated the run record.';
-- Set comment to column: "updated_by_service_identity_id" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."updated_by_service_identity_id" IS 'Service identity that last updated the run record.';
-- Set comment to column: "row_version" on table: "reconciliation_runs"
COMMENT ON COLUMN "reconciliation"."reconciliation_runs"."row_version" IS 'Optimistic concurrency version.';
-- Create "settlement_comparison_records" table
CREATE TABLE "reconciliation"."settlement_comparison_records" (
  "settlement_comparison_record_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "reconciliation_item_id" uuid NOT NULL,
  "mops_transaction_record_id" uuid NULL,
  "reconciliation_exception_id" uuid NULL,
  "payment_confirmation_id" uuid NULL,
  "provider_outcome_id" uuid NULL,
  "comparison_source_type" "reconciliation"."settlement_comparison_source_type_enum" NOT NULL,
  "comparison_source_ref" character varying(128) NULL,
  "currency_code" character(3) NOT NULL,
  "expected_amount" numeric(18,2) NOT NULL,
  "actual_amount" numeric(18,2) NOT NULL,
  "variance_amount" numeric(18,2) NOT NULL,
  "comparison_result" "reconciliation"."settlement_comparison_result_enum" NOT NULL,
  "mismatch_reason_code" character varying(64) NULL,
  "evidence_ref" character varying(256) NULL,
  "evidence_hash" character(64) NULL,
  "compared_at" timestamptz NOT NULL,
  "compared_by_user_id" uuid NULL,
  "compared_by_service_identity_id" uuid NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  CONSTRAINT "pk_settlement_comparison_records" PRIMARY KEY ("settlement_comparison_record_id")
);
-- Create index "ix_settlement_comparison_records__correlation_id" to table: "settlement_comparison_records"
CREATE INDEX "ix_settlement_comparison_records__correlation_id" ON "reconciliation"."settlement_comparison_records" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_settlement_comparison_records__mops_transaction_record_id" to table: "settlement_comparison_records"
CREATE INDEX "ix_settlement_comparison_records__mops_transaction_record_id" ON "reconciliation"."settlement_comparison_records" ("mops_transaction_record_id");
-- Create index "ix_settlement_comparison_records__payment_confirmation_id" to table: "settlement_comparison_records"
CREATE INDEX "ix_settlement_comparison_records__payment_confirmation_id" ON "reconciliation"."settlement_comparison_records" ("payment_confirmation_id");
-- Create index "ix_settlement_comparison_records__reconciliation_exception_i" to table: "settlement_comparison_records"
CREATE INDEX "ix_settlement_comparison_records__reconciliation_exception_i" ON "reconciliation"."settlement_comparison_records" ("reconciliation_exception_id");
-- Create index "ix_settlement_comparison_records__reconciliation_item_id" to table: "settlement_comparison_records"
CREATE INDEX "ix_settlement_comparison_records__reconciliation_item_id" ON "reconciliation"."settlement_comparison_records" ("reconciliation_item_id");
-- Set comment to table: "settlement_comparison_records"
COMMENT ON TABLE "reconciliation"."settlement_comparison_records" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "settlement_comparison_record_id" on table: "settlement_comparison_records"
COMMENT ON COLUMN "reconciliation"."settlement_comparison_records"."settlement_comparison_record_id" IS 'Canonical identifier of the settlement comparison record.';
-- Set comment to column: "reconciliation_item_id" on table: "settlement_comparison_records"
COMMENT ON COLUMN "reconciliation"."settlement_comparison_records"."reconciliation_item_id" IS 'Reconciliation item supported by this comparison.';
-- Set comment to column: "mops_transaction_record_id" on table: "settlement_comparison_records"
COMMENT ON COLUMN "reconciliation"."settlement_comparison_records"."mops_transaction_record_id" IS 'Related MoPS or continuity-origin record.';
-- Set comment to column: "reconciliation_exception_id" on table: "settlement_comparison_records"
COMMENT ON COLUMN "reconciliation"."settlement_comparison_records"."reconciliation_exception_id" IS 'Related reconciliation exception, where applicable.';
-- Set comment to column: "payment_confirmation_id" on table: "settlement_comparison_records"
COMMENT ON COLUMN "reconciliation"."settlement_comparison_records"."payment_confirmation_id" IS 'Related payment confirmation, where applicable.';
-- Set comment to column: "provider_outcome_id" on table: "settlement_comparison_records"
COMMENT ON COLUMN "reconciliation"."settlement_comparison_records"."provider_outcome_id" IS 'Related provider outcome, where applicable.';
-- Set comment to column: "comparison_source_type" on table: "settlement_comparison_records"
COMMENT ON COLUMN "reconciliation"."settlement_comparison_records"."comparison_source_type" IS 'Type of settlement or financial source used.';
-- Set comment to column: "comparison_source_ref" on table: "settlement_comparison_records"
COMMENT ON COLUMN "reconciliation"."settlement_comparison_records"."comparison_source_ref" IS 'Source settlement, bank, batch, or report reference.';
-- Set comment to column: "currency_code" on table: "settlement_comparison_records"
COMMENT ON COLUMN "reconciliation"."settlement_comparison_records"."currency_code" IS 'Currency code.';
-- Set comment to column: "expected_amount" on table: "settlement_comparison_records"
COMMENT ON COLUMN "reconciliation"."settlement_comparison_records"."expected_amount" IS 'Expected amount.';
-- Set comment to column: "actual_amount" on table: "settlement_comparison_records"
COMMENT ON COLUMN "reconciliation"."settlement_comparison_records"."actual_amount" IS 'Actual amount from settlement evidence.';
-- Set comment to column: "variance_amount" on table: "settlement_comparison_records"
COMMENT ON COLUMN "reconciliation"."settlement_comparison_records"."variance_amount" IS 'Actual minus expected amount.';
-- Set comment to column: "comparison_result" on table: "settlement_comparison_records"
COMMENT ON COLUMN "reconciliation"."settlement_comparison_records"."comparison_result" IS 'Result of settlement comparison.';
-- Set comment to column: "mismatch_reason_code" on table: "settlement_comparison_records"
COMMENT ON COLUMN "reconciliation"."settlement_comparison_records"."mismatch_reason_code" IS 'Controlled mismatch reason.';
-- Set comment to column: "evidence_ref" on table: "settlement_comparison_records"
COMMENT ON COLUMN "reconciliation"."settlement_comparison_records"."evidence_ref" IS 'Reference to settlement file, report, or evidence.';
-- Set comment to column: "evidence_hash" on table: "settlement_comparison_records"
COMMENT ON COLUMN "reconciliation"."settlement_comparison_records"."evidence_hash" IS 'Hash of settlement evidence where applicable.';
-- Set comment to column: "compared_at" on table: "settlement_comparison_records"
COMMENT ON COLUMN "reconciliation"."settlement_comparison_records"."compared_at" IS 'Timestamp when comparison was performed.';
-- Set comment to column: "compared_by_user_id" on table: "settlement_comparison_records"
COMMENT ON COLUMN "reconciliation"."settlement_comparison_records"."compared_by_user_id" IS 'User who performed comparison.';
-- Set comment to column: "compared_by_service_identity_id" on table: "settlement_comparison_records"
COMMENT ON COLUMN "reconciliation"."settlement_comparison_records"."compared_by_service_identity_id" IS 'Service identity that performed comparison.';
-- Set comment to column: "correlation_id" on table: "settlement_comparison_records"
COMMENT ON COLUMN "reconciliation"."settlement_comparison_records"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "settlement_comparison_records"
COMMENT ON COLUMN "reconciliation"."settlement_comparison_records"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "settlement_comparison_records"
COMMENT ON COLUMN "reconciliation"."settlement_comparison_records"."created_by_user_id" IS 'User who created the comparison.';
-- Set comment to column: "created_by_service_identity_id" on table: "settlement_comparison_records"
COMMENT ON COLUMN "reconciliation"."settlement_comparison_records"."created_by_service_identity_id" IS 'Service identity that created the comparison.';
-- Create enum type "session_identifier_status_enum"
CREATE TYPE "sessions"."session_identifier_status_enum" AS ENUM ('ACTIVE', 'EXPIRED', 'INVALIDATED', 'SUPERSEDED');
-- Create enum type "session_lookup_cache_status_enum"
CREATE TYPE "sessions"."session_lookup_cache_status_enum" AS ENUM ('ACTIVE', 'EXPIRED', 'INVALIDATED', 'SUPERSEDED');
-- Create enum type "session_lookup_type_enum"
CREATE TYPE "sessions"."session_lookup_type_enum" AS ENUM ('PLATE_NUMBER', 'TICKET_NUMBER', 'VENDOR_SESSION_REF', 'QR_REFERENCE', 'COMBINED_PLATE_TICKET');
-- Create enum type "session_resolution_channel_enum"
CREATE TYPE "sessions"."session_resolution_channel_enum" AS ENUM ('WEB_PAY', 'OPERATOR_ASSISTED', 'INTERNAL_SERVICE', 'RECONCILIATION_RECHECK', 'SUPPORT_RECHECK');
-- Create enum type "session_resolution_request_status_enum"
CREATE TYPE "sessions"."session_resolution_request_status_enum" AS ENUM ('REQUESTED', 'PROCESSING', 'COMPLETED', 'FAILED', 'EXPIRED', 'CANCELLED');
-- Create enum type "session_resolution_result_status_enum"
CREATE TYPE "sessions"."session_resolution_result_status_enum" AS ENUM ('RESOLVED_SINGLE', 'NOT_FOUND', 'AMBIGUOUS', 'FAILED', 'EXPIRED', 'CANCELLED');
-- Create "session_identifier_indexes" table
CREATE TABLE "sessions"."session_identifier_indexes" (
  "session_identifier_index_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "parking_session_id" uuid NULL,
  "site_group_id" uuid NOT NULL,
  "site_id" uuid NULL,
  "vendor_system_id" uuid NULL,
  "identifier_type" "sessions"."session_lookup_type_enum" NOT NULL,
  "identifier_hash" character(64) NOT NULL,
  "identifier_masked" character varying(64) NULL,
  "identifier_status" "sessions"."session_identifier_status_enum" NOT NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_service_identity_id" uuid NULL,
  "correlation_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_session_identifier_indexes" PRIMARY KEY ("session_identifier_index_id")
);
-- Create index "ix_session_identifier_indexes__correlation_id" to table: "session_identifier_indexes"
CREATE INDEX "ix_session_identifier_indexes__correlation_id" ON "sessions"."session_identifier_indexes" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_session_identifier_indexes__parking_session_id" to table: "session_identifier_indexes"
CREATE INDEX "ix_session_identifier_indexes__parking_session_id" ON "sessions"."session_identifier_indexes" ("parking_session_id");
-- Create index "ix_session_identifier_indexes__site_group_id" to table: "session_identifier_indexes"
CREATE INDEX "ix_session_identifier_indexes__site_group_id" ON "sessions"."session_identifier_indexes" ("site_group_id");
-- Create index "ix_session_identifier_indexes__site_id" to table: "session_identifier_indexes"
CREATE INDEX "ix_session_identifier_indexes__site_id" ON "sessions"."session_identifier_indexes" ("site_id");
-- Create index "ix_session_identifier_indexes__vendor_system_id" to table: "session_identifier_indexes"
CREATE INDEX "ix_session_identifier_indexes__vendor_system_id" ON "sessions"."session_identifier_indexes" ("vendor_system_id");
-- Create index "ux_session_identifier_indexes__active_scope_with_site" to table: "session_identifier_indexes"
CREATE UNIQUE INDEX "ux_session_identifier_indexes__active_scope_with_site" ON "sessions"."session_identifier_indexes" ("site_group_id", "site_id", "identifier_type", "identifier_hash") WHERE ((identifier_status = 'ACTIVE'::sessions.session_identifier_status_enum) AND (site_id IS NOT NULL));
-- Create index "ux_session_identifier_indexes__active_scope_without_site" to table: "session_identifier_indexes"
CREATE UNIQUE INDEX "ux_session_identifier_indexes__active_scope_without_site" ON "sessions"."session_identifier_indexes" ("site_group_id", "identifier_type", "identifier_hash") WHERE ((identifier_status = 'ACTIVE'::sessions.session_identifier_status_enum) AND (site_id IS NULL));
-- Set comment to table: "session_identifier_indexes"
COMMENT ON TABLE "sessions"."session_identifier_indexes" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "session_identifier_index_id" on table: "session_identifier_indexes"
COMMENT ON COLUMN "sessions"."session_identifier_indexes"."session_identifier_index_id" IS 'Canonical identifier of the identifier index record.';
-- Set comment to column: "parking_session_id" on table: "session_identifier_indexes"
COMMENT ON COLUMN "sessions"."session_identifier_indexes"."parking_session_id" IS 'Canonical parking session associated with the identifier.';
-- Set comment to column: "site_group_id" on table: "session_identifier_indexes"
COMMENT ON COLUMN "sessions"."session_identifier_indexes"."site_group_id" IS 'Site group scope for identifier lookup.';
-- Set comment to column: "site_id" on table: "session_identifier_indexes"
COMMENT ON COLUMN "sessions"."session_identifier_indexes"."site_id" IS 'Site context where known.';
-- Set comment to column: "vendor_system_id" on table: "session_identifier_indexes"
COMMENT ON COLUMN "sessions"."session_identifier_indexes"."vendor_system_id" IS 'Vendor system context where identifier is vendor-originated.';
-- Set comment to column: "identifier_type" on table: "session_identifier_indexes"
COMMENT ON COLUMN "sessions"."session_identifier_indexes"."identifier_type" IS 'Identifier type.';
-- Set comment to column: "identifier_hash" on table: "session_identifier_indexes"
COMMENT ON COLUMN "sessions"."session_identifier_indexes"."identifier_hash" IS 'Hash of normalized identifier.';
-- Set comment to column: "identifier_masked" on table: "session_identifier_indexes"
COMMENT ON COLUMN "sessions"."session_identifier_indexes"."identifier_masked" IS 'Masked display value.';
-- Set comment to column: "identifier_status" on table: "session_identifier_indexes"
COMMENT ON COLUMN "sessions"."session_identifier_indexes"."identifier_status" IS 'Identifier lifecycle state.';
-- Set comment to column: "effective_from" on table: "session_identifier_indexes"
COMMENT ON COLUMN "sessions"."session_identifier_indexes"."effective_from" IS 'Start of identifier validity.';
-- Set comment to column: "effective_to" on table: "session_identifier_indexes"
COMMENT ON COLUMN "sessions"."session_identifier_indexes"."effective_to" IS 'End of identifier validity.';
-- Set comment to column: "created_at" on table: "session_identifier_indexes"
COMMENT ON COLUMN "sessions"."session_identifier_indexes"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_service_identity_id" on table: "session_identifier_indexes"
COMMENT ON COLUMN "sessions"."session_identifier_indexes"."created_by_service_identity_id" IS 'Service identity that created the identifier index.';
-- Set comment to column: "updated_at" on table: "session_identifier_indexes"
COMMENT ON COLUMN "sessions"."session_identifier_indexes"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_service_identity_id" on table: "session_identifier_indexes"
COMMENT ON COLUMN "sessions"."session_identifier_indexes"."updated_by_service_identity_id" IS 'Service identity that last updated the identifier index.';
-- Set comment to column: "correlation_id" on table: "session_identifier_indexes"
COMMENT ON COLUMN "sessions"."session_identifier_indexes"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "row_version" on table: "session_identifier_indexes"
COMMENT ON COLUMN "sessions"."session_identifier_indexes"."row_version" IS 'Optimistic concurrency version.';
-- Create "session_lookup_cache" table
CREATE TABLE "sessions"."session_lookup_cache" (
  "session_lookup_cache_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "site_group_id" uuid NOT NULL,
  "site_id" uuid NULL,
  "parking_session_id" uuid NULL,
  "vendor_system_id" uuid NULL,
  "lookup_type" "sessions"."session_lookup_type_enum" NOT NULL,
  "lookup_identifier_hash" character(64) NOT NULL,
  "result_status" "sessions"."session_resolution_result_status_enum" NOT NULL,
  "cache_status" "sessions"."session_lookup_cache_status_enum" NOT NULL,
  "cached_at" timestamptz NOT NULL,
  "expires_at" timestamptz NOT NULL,
  "invalidated_at" timestamptz NULL,
  "invalidation_reason_code" character varying(64) NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_session_lookup_cache" PRIMARY KEY ("session_lookup_cache_id")
);
-- Create index "ix_session_lookup_cache__correlation_id" to table: "session_lookup_cache"
CREATE INDEX "ix_session_lookup_cache__correlation_id" ON "sessions"."session_lookup_cache" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_session_lookup_cache__parking_session_id" to table: "session_lookup_cache"
CREATE INDEX "ix_session_lookup_cache__parking_session_id" ON "sessions"."session_lookup_cache" ("parking_session_id");
-- Create index "ix_session_lookup_cache__site_group_id" to table: "session_lookup_cache"
CREATE INDEX "ix_session_lookup_cache__site_group_id" ON "sessions"."session_lookup_cache" ("site_group_id");
-- Create index "ix_session_lookup_cache__site_id" to table: "session_lookup_cache"
CREATE INDEX "ix_session_lookup_cache__site_id" ON "sessions"."session_lookup_cache" ("site_id");
-- Create index "ix_session_lookup_cache__vendor_system_id" to table: "session_lookup_cache"
CREATE INDEX "ix_session_lookup_cache__vendor_system_id" ON "sessions"."session_lookup_cache" ("vendor_system_id");
-- Create index "ux_session_lookup_cache__active_scope_with_site" to table: "session_lookup_cache"
CREATE UNIQUE INDEX "ux_session_lookup_cache__active_scope_with_site" ON "sessions"."session_lookup_cache" ("site_group_id", "site_id", "lookup_type", "lookup_identifier_hash") WHERE ((cache_status = 'ACTIVE'::sessions.session_lookup_cache_status_enum) AND (site_id IS NOT NULL));
-- Create index "ux_session_lookup_cache__active_scope_without_site" to table: "session_lookup_cache"
CREATE UNIQUE INDEX "ux_session_lookup_cache__active_scope_without_site" ON "sessions"."session_lookup_cache" ("site_group_id", "lookup_type", "lookup_identifier_hash") WHERE ((cache_status = 'ACTIVE'::sessions.session_lookup_cache_status_enum) AND (site_id IS NULL));
-- Set comment to table: "session_lookup_cache"
COMMENT ON TABLE "sessions"."session_lookup_cache" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "session_lookup_cache_id" on table: "session_lookup_cache"
COMMENT ON COLUMN "sessions"."session_lookup_cache"."session_lookup_cache_id" IS 'Canonical identifier of the cache entry.';
-- Set comment to column: "site_group_id" on table: "session_lookup_cache"
COMMENT ON COLUMN "sessions"."session_lookup_cache"."site_group_id" IS 'Site group scope of the cached lookup.';
-- Set comment to column: "site_id" on table: "session_lookup_cache"
COMMENT ON COLUMN "sessions"."session_lookup_cache"."site_id" IS 'Site context where known.';
-- Set comment to column: "parking_session_id" on table: "session_lookup_cache"
COMMENT ON COLUMN "sessions"."session_lookup_cache"."parking_session_id" IS 'Canonical parking session if lookup was resolved.';
-- Set comment to column: "vendor_system_id" on table: "session_lookup_cache"
COMMENT ON COLUMN "sessions"."session_lookup_cache"."vendor_system_id" IS 'Vendor PMS that produced the cached result.';
-- Set comment to column: "lookup_type" on table: "session_lookup_cache"
COMMENT ON COLUMN "sessions"."session_lookup_cache"."lookup_type" IS 'Lookup identifier type.';
-- Set comment to column: "lookup_identifier_hash" on table: "session_lookup_cache"
COMMENT ON COLUMN "sessions"."session_lookup_cache"."lookup_identifier_hash" IS 'Hash of normalized lookup identifier.';
-- Set comment to column: "result_status" on table: "session_lookup_cache"
COMMENT ON COLUMN "sessions"."session_lookup_cache"."result_status" IS 'Cached result status.';
-- Set comment to column: "cache_status" on table: "session_lookup_cache"
COMMENT ON COLUMN "sessions"."session_lookup_cache"."cache_status" IS 'Cache entry lifecycle state.';
-- Set comment to column: "cached_at" on table: "session_lookup_cache"
COMMENT ON COLUMN "sessions"."session_lookup_cache"."cached_at" IS 'Timestamp when cache entry was created.';
-- Set comment to column: "expires_at" on table: "session_lookup_cache"
COMMENT ON COLUMN "sessions"."session_lookup_cache"."expires_at" IS 'Cache entry expiry timestamp.';
-- Set comment to column: "invalidated_at" on table: "session_lookup_cache"
COMMENT ON COLUMN "sessions"."session_lookup_cache"."invalidated_at" IS 'Timestamp when cache entry was invalidated.';
-- Set comment to column: "invalidation_reason_code" on table: "session_lookup_cache"
COMMENT ON COLUMN "sessions"."session_lookup_cache"."invalidation_reason_code" IS 'Controlled invalidation reason.';
-- Set comment to column: "correlation_id" on table: "session_lookup_cache"
COMMENT ON COLUMN "sessions"."session_lookup_cache"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "session_lookup_cache"
COMMENT ON COLUMN "sessions"."session_lookup_cache"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_service_identity_id" on table: "session_lookup_cache"
COMMENT ON COLUMN "sessions"."session_lookup_cache"."created_by_service_identity_id" IS 'Service identity that created the cache entry.';
-- Set comment to column: "row_version" on table: "session_lookup_cache"
COMMENT ON COLUMN "sessions"."session_lookup_cache"."row_version" IS 'Optimistic concurrency version.';
-- Create "session_resolution_requests" table
CREATE TABLE "sessions"."session_resolution_requests" (
  "session_resolution_request_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "site_group_id" uuid NOT NULL,
  "site_id" uuid NULL,
  "lookup_type" "sessions"."session_lookup_type_enum" NOT NULL,
  "lookup_identifier_hash" character(64) NOT NULL,
  "lookup_identifier_masked" character varying(64) NULL,
  "request_channel" "sessions"."session_resolution_channel_enum" NOT NULL,
  "request_status" "sessions"."session_resolution_request_status_enum" NOT NULL,
  "client_reference" character varying(128) NULL,
  "idempotency_key" character varying(128) NULL,
  "rate_limit_key_hash" character(64) NULL,
  "requested_at" timestamptz NOT NULL,
  "expires_at" timestamptz NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_session_resolution_requests" PRIMARY KEY ("session_resolution_request_id")
);
-- Create index "ix_session_resolution_requests__correlation_id" to table: "session_resolution_requests"
CREATE INDEX "ix_session_resolution_requests__correlation_id" ON "sessions"."session_resolution_requests" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_session_resolution_requests__request_status" to table: "session_resolution_requests"
CREATE INDEX "ix_session_resolution_requests__request_status" ON "sessions"."session_resolution_requests" ("request_status");
-- Create index "ix_session_resolution_requests__requested_at" to table: "session_resolution_requests"
CREATE INDEX "ix_session_resolution_requests__requested_at" ON "sessions"."session_resolution_requests" ("requested_at");
-- Create index "ix_session_resolution_requests__site_group_id" to table: "session_resolution_requests"
CREATE INDEX "ix_session_resolution_requests__site_group_id" ON "sessions"."session_resolution_requests" ("site_group_id");
-- Create index "ix_session_resolution_requests__site_id" to table: "session_resolution_requests"
CREATE INDEX "ix_session_resolution_requests__site_id" ON "sessions"."session_resolution_requests" ("site_id");
-- Create index "ux_session_resolution_requests__idempotency_key" to table: "session_resolution_requests"
CREATE UNIQUE INDEX "ux_session_resolution_requests__idempotency_key" ON "sessions"."session_resolution_requests" ("idempotency_key") WHERE (idempotency_key IS NOT NULL);
-- Set comment to table: "session_resolution_requests"
COMMENT ON TABLE "sessions"."session_resolution_requests" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "session_resolution_request_id" on table: "session_resolution_requests"
COMMENT ON COLUMN "sessions"."session_resolution_requests"."session_resolution_request_id" IS 'Canonical identifier of the lookup request.';
-- Set comment to column: "site_group_id" on table: "session_resolution_requests"
COMMENT ON COLUMN "sessions"."session_resolution_requests"."site_group_id" IS 'Site group scope used for lookup.';
-- Set comment to column: "site_id" on table: "session_resolution_requests"
COMMENT ON COLUMN "sessions"."session_resolution_requests"."site_id" IS 'Specific site scope, if already known.';
-- Set comment to column: "lookup_type" on table: "session_resolution_requests"
COMMENT ON COLUMN "sessions"."session_resolution_requests"."lookup_type" IS 'Type of lookup submitted.';
-- Set comment to column: "lookup_identifier_hash" on table: "session_resolution_requests"
COMMENT ON COLUMN "sessions"."session_resolution_requests"."lookup_identifier_hash" IS 'Hash of normalized lookup identifier.';
-- Set comment to column: "lookup_identifier_masked" on table: "session_resolution_requests"
COMMENT ON COLUMN "sessions"."session_resolution_requests"."lookup_identifier_masked" IS 'Masked display value of submitted identifier.';
-- Set comment to column: "request_channel" on table: "session_resolution_requests"
COMMENT ON COLUMN "sessions"."session_resolution_requests"."request_channel" IS 'Channel where request originated.';
-- Set comment to column: "request_status" on table: "session_resolution_requests"
COMMENT ON COLUMN "sessions"."session_resolution_requests"."request_status" IS 'Request lifecycle state.';
-- Set comment to column: "client_reference" on table: "session_resolution_requests"
COMMENT ON COLUMN "sessions"."session_resolution_requests"."client_reference" IS 'Optional client-side or UI flow reference.';
-- Set comment to column: "idempotency_key" on table: "session_resolution_requests"
COMMENT ON COLUMN "sessions"."session_resolution_requests"."idempotency_key" IS 'Idempotency key for repeated lookup request, where used.';
-- Set comment to column: "rate_limit_key_hash" on table: "session_resolution_requests"
COMMENT ON COLUMN "sessions"."session_resolution_requests"."rate_limit_key_hash" IS 'Hashed rate-limit key where lookup throttling applies.';
-- Set comment to column: "requested_at" on table: "session_resolution_requests"
COMMENT ON COLUMN "sessions"."session_resolution_requests"."requested_at" IS 'Lookup request timestamp.';
-- Set comment to column: "expires_at" on table: "session_resolution_requests"
COMMENT ON COLUMN "sessions"."session_resolution_requests"."expires_at" IS 'Request expiry timestamp where lookup has a bounded validity window.';
-- Set comment to column: "correlation_id" on table: "session_resolution_requests"
COMMENT ON COLUMN "sessions"."session_resolution_requests"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "session_resolution_requests"
COMMENT ON COLUMN "sessions"."session_resolution_requests"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "session_resolution_requests"
COMMENT ON COLUMN "sessions"."session_resolution_requests"."created_by_user_id" IS 'Human user who created the request, if operator-assisted.';
-- Set comment to column: "created_by_service_identity_id" on table: "session_resolution_requests"
COMMENT ON COLUMN "sessions"."session_resolution_requests"."created_by_service_identity_id" IS 'Service identity that created the request.';
-- Set comment to column: "row_version" on table: "session_resolution_requests"
COMMENT ON COLUMN "sessions"."session_resolution_requests"."row_version" IS 'Optimistic concurrency version.';
-- Create "session_resolution_results" table
CREATE TABLE "sessions"."session_resolution_results" (
  "session_resolution_result_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "session_resolution_request_id" uuid NOT NULL,
  "parking_session_id" uuid NULL,
  "site_group_id" uuid NOT NULL,
  "site_id" uuid NULL,
  "vendor_system_id" uuid NULL,
  "vendor_session_ref" character varying(128) NULL,
  "result_status" "sessions"."session_resolution_result_status_enum" NOT NULL,
  "match_count" integer NOT NULL,
  "ambiguity_reason_code" character varying(64) NULL,
  "failure_reason_code" character varying(64) NULL,
  "resolved_at" timestamptz NOT NULL,
  "expires_at" timestamptz NULL,
  "raw_result_ref" character varying(256) NULL,
  "correlation_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_service_identity_id" uuid NOT NULL,
  CONSTRAINT "pk_session_resolution_results" PRIMARY KEY ("session_resolution_result_id")
);
-- Create index "ix_session_resolution_results__correlation_id" to table: "session_resolution_results"
CREATE INDEX "ix_session_resolution_results__correlation_id" ON "sessions"."session_resolution_results" ("correlation_id") WHERE (correlation_id IS NOT NULL);
-- Create index "ix_session_resolution_results__parking_session_id" to table: "session_resolution_results"
CREATE INDEX "ix_session_resolution_results__parking_session_id" ON "sessions"."session_resolution_results" ("parking_session_id");
-- Create index "ix_session_resolution_results__session_resolution_request_id" to table: "session_resolution_results"
CREATE INDEX "ix_session_resolution_results__session_resolution_request_id" ON "sessions"."session_resolution_results" ("session_resolution_request_id");
-- Create index "ix_session_resolution_results__site_group_id" to table: "session_resolution_results"
CREATE INDEX "ix_session_resolution_results__site_group_id" ON "sessions"."session_resolution_results" ("site_group_id");
-- Create index "ix_session_resolution_results__site_id" to table: "session_resolution_results"
CREATE INDEX "ix_session_resolution_results__site_id" ON "sessions"."session_resolution_results" ("site_id");
-- Set comment to table: "session_resolution_results"
COMMENT ON TABLE "sessions"."session_resolution_results" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "session_resolution_result_id" on table: "session_resolution_results"
COMMENT ON COLUMN "sessions"."session_resolution_results"."session_resolution_result_id" IS 'Canonical identifier of the lookup result.';
-- Set comment to column: "session_resolution_request_id" on table: "session_resolution_results"
COMMENT ON COLUMN "sessions"."session_resolution_results"."session_resolution_request_id" IS 'Lookup request that produced this result.';
-- Set comment to column: "parking_session_id" on table: "session_resolution_results"
COMMENT ON COLUMN "sessions"."session_resolution_results"."parking_session_id" IS 'Canonical parking session created or reused after deterministic match.';
-- Set comment to column: "site_group_id" on table: "session_resolution_results"
COMMENT ON COLUMN "sessions"."session_resolution_results"."site_group_id" IS 'Site group scope used for lookup.';
-- Set comment to column: "site_id" on table: "session_resolution_results"
COMMENT ON COLUMN "sessions"."session_resolution_results"."site_id" IS 'Resolved site, where known.';
-- Set comment to column: "vendor_system_id" on table: "session_resolution_results"
COMMENT ON COLUMN "sessions"."session_resolution_results"."vendor_system_id" IS 'Vendor PMS that produced the lookup result.';
-- Set comment to column: "vendor_session_ref" on table: "session_resolution_results"
COMMENT ON COLUMN "sessions"."session_resolution_results"."vendor_session_ref" IS 'Vendor PMS session reference if resolved.';
-- Set comment to column: "result_status" on table: "session_resolution_results"
COMMENT ON COLUMN "sessions"."session_resolution_results"."result_status" IS 'Lookup outcome.';
-- Set comment to column: "match_count" on table: "session_resolution_results"
COMMENT ON COLUMN "sessions"."session_resolution_results"."match_count" IS 'Number of matches returned or determined.';
-- Set comment to column: "ambiguity_reason_code" on table: "session_resolution_results"
COMMENT ON COLUMN "sessions"."session_resolution_results"."ambiguity_reason_code" IS 'Controlled reason when result is ambiguous.';
-- Set comment to column: "failure_reason_code" on table: "session_resolution_results"
COMMENT ON COLUMN "sessions"."session_resolution_results"."failure_reason_code" IS 'Controlled reason when lookup failed.';
-- Set comment to column: "resolved_at" on table: "session_resolution_results"
COMMENT ON COLUMN "sessions"."session_resolution_results"."resolved_at" IS 'Timestamp when result was resolved.';
-- Set comment to column: "expires_at" on table: "session_resolution_results"
COMMENT ON COLUMN "sessions"."session_resolution_results"."expires_at" IS 'Expiry of result usability.';
-- Set comment to column: "raw_result_ref" on table: "session_resolution_results"
COMMENT ON COLUMN "sessions"."session_resolution_results"."raw_result_ref" IS 'Reference to raw vendor lookup result where retained.';
-- Set comment to column: "correlation_id" on table: "session_resolution_results"
COMMENT ON COLUMN "sessions"."session_resolution_results"."correlation_id" IS 'Cross-service correlation identifier.';
-- Set comment to column: "created_at" on table: "session_resolution_results"
COMMENT ON COLUMN "sessions"."session_resolution_results"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_service_identity_id" on table: "session_resolution_results"
COMMENT ON COLUMN "sessions"."session_resolution_results"."created_by_service_identity_id" IS 'Service identity that created the result.';
-- Create enum type "device_assignment_status_enum"
CREATE TYPE "sites"."device_assignment_status_enum" AS ENUM ('ACTIVE', 'SUSPENDED', 'SUPERSEDED', 'EXPIRED', 'RETIRED');
-- Create enum type "device_assignment_type_enum"
CREATE TYPE "sites"."device_assignment_type_enum" AS ENUM ('GATE_DEVICE', 'LPR_DEVICE', 'LANE_CONTROLLER', 'PAYMENT_DEVICE', 'SERVICE_PRINCIPAL', 'OTHER');
-- Create enum type "lane_direction_enum"
CREATE TYPE "sites"."lane_direction_enum" AS ENUM ('INBOUND', 'OUTBOUND', 'BIDIRECTIONAL', 'NOT_APPLICABLE');
-- Create enum type "lane_status_enum"
CREATE TYPE "sites"."lane_status_enum" AS ENUM ('DRAFT', 'ACTIVE', 'MAINTENANCE', 'SUSPENDED', 'INACTIVE', 'RETIRED');
-- Create enum type "lane_type_enum"
CREATE TYPE "sites"."lane_type_enum" AS ENUM ('ENTRY', 'EXIT', 'MIXED', 'VALIDATION', 'SERVICE', 'OTHER');
-- Create enum type "site_group_status_enum"
CREATE TYPE "sites"."site_group_status_enum" AS ENUM ('DRAFT', 'ACTIVE', 'SUSPENDED', 'INACTIVE', 'RETIRED');
-- Create enum type "site_status_enum"
CREATE TYPE "sites"."site_status_enum" AS ENUM ('DRAFT', 'ACTIVE', 'SUSPENDED', 'INACTIVE', 'RETIRED');
-- Create enum type "site_type_enum"
CREATE TYPE "sites"."site_type_enum" AS ENUM ('OPEN_LOT', 'STRUCTURED_PARKING', 'MALL_PARKING', 'MIXED_USE_PROPERTY', 'TERMINAL', 'CAMPUS', 'OTHER');
-- Create "device_assignments" table
CREATE TABLE "sites"."device_assignments" (
  "device_assignment_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "site_id" uuid NOT NULL,
  "lane_id" uuid NULL,
  "gate_device_id" uuid NULL,
  "service_identity_id" uuid NULL,
  "assignment_type" "sites"."device_assignment_type_enum" NOT NULL,
  "assignment_status" "sites"."device_assignment_status_enum" NOT NULL,
  "assignment_reason_code" character varying(64) NULL,
  "assigned_at" timestamptz NOT NULL DEFAULT now(),
  "unassigned_at" timestamptz NULL,
  "assigned_by_user_id" uuid NULL,
  "assigned_by_service_identity_id" uuid NULL,
  "unassigned_by_user_id" uuid NULL,
  "unassigned_by_service_identity_id" uuid NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_device_assignments" PRIMARY KEY ("device_assignment_id")
);
-- Create index "ix_device_assignments__gate_device_id" to table: "device_assignments"
CREATE INDEX "ix_device_assignments__gate_device_id" ON "sites"."device_assignments" ("gate_device_id");
-- Create index "ix_device_assignments__lane_id" to table: "device_assignments"
CREATE INDEX "ix_device_assignments__lane_id" ON "sites"."device_assignments" ("lane_id");
-- Create index "ix_device_assignments__site_id" to table: "device_assignments"
CREATE INDEX "ix_device_assignments__site_id" ON "sites"."device_assignments" ("site_id");
-- Create index "ux_device_assignments__active_gate_device" to table: "device_assignments"
CREATE UNIQUE INDEX "ux_device_assignments__active_gate_device" ON "sites"."device_assignments" ("gate_device_id") WHERE ((assignment_status = 'ACTIVE'::sites.device_assignment_status_enum) AND (gate_device_id IS NOT NULL));
-- Create index "ux_device_assignments__active_lane_assignment_type" to table: "device_assignments"
CREATE UNIQUE INDEX "ux_device_assignments__active_lane_assignment_type" ON "sites"."device_assignments" ("site_id", "lane_id", "assignment_type") WHERE ((assignment_status = 'ACTIVE'::sites.device_assignment_status_enum) AND (lane_id IS NOT NULL));
-- Create index "ux_device_assignments__active_service_identity" to table: "device_assignments"
CREATE UNIQUE INDEX "ux_device_assignments__active_service_identity" ON "sites"."device_assignments" ("service_identity_id") WHERE ((assignment_status = 'ACTIVE'::sites.device_assignment_status_enum) AND (service_identity_id IS NOT NULL));
-- Set comment to table: "device_assignments"
COMMENT ON TABLE "sites"."device_assignments" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "device_assignment_id" on table: "device_assignments"
COMMENT ON COLUMN "sites"."device_assignments"."device_assignment_id" IS 'Canonical identifier of the device assignment.';
-- Set comment to column: "site_id" on table: "device_assignments"
COMMENT ON COLUMN "sites"."device_assignments"."site_id" IS 'Site where the device is assigned.';
-- Set comment to column: "lane_id" on table: "device_assignments"
COMMENT ON COLUMN "sites"."device_assignments"."lane_id" IS 'Lane where the device is assigned, if lane-specific.';
-- Set comment to column: "gate_device_id" on table: "device_assignments"
COMMENT ON COLUMN "sites"."device_assignments"."gate_device_id" IS 'Gate device being assigned, where applicable.';
-- Set comment to column: "service_identity_id" on table: "device_assignments"
COMMENT ON COLUMN "sites"."device_assignments"."service_identity_id" IS 'Service or device principal associated with the assignment, where applicable.';
-- Set comment to column: "assignment_type" on table: "device_assignments"
COMMENT ON COLUMN "sites"."device_assignments"."assignment_type" IS 'Type of assignment.';
-- Set comment to column: "assignment_status" on table: "device_assignments"
COMMENT ON COLUMN "sites"."device_assignments"."assignment_status" IS 'Assignment lifecycle state.';
-- Set comment to column: "assignment_reason_code" on table: "device_assignments"
COMMENT ON COLUMN "sites"."device_assignments"."assignment_reason_code" IS 'Controlled assignment or reassignment reason.';
-- Set comment to column: "assigned_at" on table: "device_assignments"
COMMENT ON COLUMN "sites"."device_assignments"."assigned_at" IS 'Assignment start timestamp.';
-- Set comment to column: "unassigned_at" on table: "device_assignments"
COMMENT ON COLUMN "sites"."device_assignments"."unassigned_at" IS 'Assignment end timestamp.';
-- Set comment to column: "assigned_by_user_id" on table: "device_assignments"
COMMENT ON COLUMN "sites"."device_assignments"."assigned_by_user_id" IS 'User who assigned the device.';
-- Set comment to column: "assigned_by_service_identity_id" on table: "device_assignments"
COMMENT ON COLUMN "sites"."device_assignments"."assigned_by_service_identity_id" IS 'Service identity that assigned the device.';
-- Set comment to column: "unassigned_by_user_id" on table: "device_assignments"
COMMENT ON COLUMN "sites"."device_assignments"."unassigned_by_user_id" IS 'User who ended the assignment.';
-- Set comment to column: "unassigned_by_service_identity_id" on table: "device_assignments"
COMMENT ON COLUMN "sites"."device_assignments"."unassigned_by_service_identity_id" IS 'Service identity that ended the assignment.';
-- Set comment to column: "created_at" on table: "device_assignments"
COMMENT ON COLUMN "sites"."device_assignments"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "device_assignments"
COMMENT ON COLUMN "sites"."device_assignments"."created_by_user_id" IS 'User who created the record.';
-- Set comment to column: "created_by_service_identity_id" on table: "device_assignments"
COMMENT ON COLUMN "sites"."device_assignments"."created_by_service_identity_id" IS 'Service identity that created the record.';
-- Set comment to column: "updated_at" on table: "device_assignments"
COMMENT ON COLUMN "sites"."device_assignments"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "device_assignments"
COMMENT ON COLUMN "sites"."device_assignments"."updated_by_user_id" IS 'User who last updated the record.';
-- Set comment to column: "updated_by_service_identity_id" on table: "device_assignments"
COMMENT ON COLUMN "sites"."device_assignments"."updated_by_service_identity_id" IS 'Service identity that last updated the record.';
-- Set comment to column: "row_version" on table: "device_assignments"
COMMENT ON COLUMN "sites"."device_assignments"."row_version" IS 'Optimistic concurrency version.';
-- Create "lanes" table
CREATE TABLE "sites"."lanes" (
  "lane_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "site_id" uuid NOT NULL,
  "lane_code" character varying(64) NOT NULL,
  "lane_name" character varying(128) NOT NULL,
  "lane_description" text NULL,
  "lane_type" "sites"."lane_type_enum" NOT NULL,
  "lane_direction" "sites"."lane_direction_enum" NOT NULL,
  "lane_status" "sites"."lane_status_enum" NOT NULL,
  "display_order" integer NULL,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_lanes" PRIMARY KEY ("lane_id"),
  CONSTRAINT "uq_lanes__site_lane_code" UNIQUE ("site_id", "lane_code")
);
-- Create index "ix_lanes__lane_status" to table: "lanes"
CREATE INDEX "ix_lanes__lane_status" ON "sites"."lanes" ("lane_status");
-- Create index "ix_lanes__site_id" to table: "lanes"
CREATE INDEX "ix_lanes__site_id" ON "sites"."lanes" ("site_id");
-- Set comment to table: "lanes"
COMMENT ON TABLE "sites"."lanes" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "lane_id" on table: "lanes"
COMMENT ON COLUMN "sites"."lanes"."lane_id" IS 'Canonical identifier of the lane.';
-- Set comment to column: "site_id" on table: "lanes"
COMMENT ON COLUMN "sites"."lanes"."site_id" IS 'Parent site.';
-- Set comment to column: "lane_code" on table: "lanes"
COMMENT ON COLUMN "sites"."lanes"."lane_code" IS 'Stable internal lane code.';
-- Set comment to column: "lane_name" on table: "lanes"
COMMENT ON COLUMN "sites"."lanes"."lane_name" IS 'Human-readable lane name.';
-- Set comment to column: "lane_description" on table: "lanes"
COMMENT ON COLUMN "sites"."lanes"."lane_description" IS 'Lane description.';
-- Set comment to column: "lane_type" on table: "lanes"
COMMENT ON COLUMN "sites"."lanes"."lane_type" IS 'Lane purpose or physical classification.';
-- Set comment to column: "lane_direction" on table: "lanes"
COMMENT ON COLUMN "sites"."lanes"."lane_direction" IS 'Directional use of the lane.';
-- Set comment to column: "lane_status" on table: "lanes"
COMMENT ON COLUMN "sites"."lanes"."lane_status" IS 'Lane lifecycle or operational status.';
-- Set comment to column: "display_order" on table: "lanes"
COMMENT ON COLUMN "sites"."lanes"."display_order" IS 'Optional display order in UI or reports.';
-- Set comment to column: "effective_from" on table: "lanes"
COMMENT ON COLUMN "sites"."lanes"."effective_from" IS 'Start of lane effectiveness.';
-- Set comment to column: "effective_to" on table: "lanes"
COMMENT ON COLUMN "sites"."lanes"."effective_to" IS 'End of lane effectiveness.';
-- Set comment to column: "created_at" on table: "lanes"
COMMENT ON COLUMN "sites"."lanes"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "lanes"
COMMENT ON COLUMN "sites"."lanes"."created_by_user_id" IS 'User who created the lane.';
-- Set comment to column: "created_by_service_identity_id" on table: "lanes"
COMMENT ON COLUMN "sites"."lanes"."created_by_service_identity_id" IS 'Service identity that created the lane.';
-- Set comment to column: "updated_at" on table: "lanes"
COMMENT ON COLUMN "sites"."lanes"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "lanes"
COMMENT ON COLUMN "sites"."lanes"."updated_by_user_id" IS 'User who last updated the lane.';
-- Set comment to column: "updated_by_service_identity_id" on table: "lanes"
COMMENT ON COLUMN "sites"."lanes"."updated_by_service_identity_id" IS 'Service identity that last updated the lane.';
-- Set comment to column: "row_version" on table: "lanes"
COMMENT ON COLUMN "sites"."lanes"."row_version" IS 'Optimistic concurrency version.';
-- Create "site_groups" table
CREATE TABLE "sites"."site_groups" (
  "site_group_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "site_group_code" character varying(64) NOT NULL,
  "site_group_name" character varying(128) NOT NULL,
  "business_label" character varying(64) NULL,
  "description" text NULL,
  "operator_entity_name" character varying(128) NULL,
  "timezone_name" character varying(64) NOT NULL,
  "default_currency_code" character(3) NOT NULL,
  "site_group_status" "sites"."site_group_status_enum" NOT NULL,
  "public_lookup_enabled" boolean NOT NULL DEFAULT false,
  "default_payment_enabled" boolean NOT NULL DEFAULT false,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_site_groups" PRIMARY KEY ("site_group_id"),
  CONSTRAINT "uq_site_groups__site_group_code" UNIQUE ("site_group_code")
);
-- Create index "ix_site_groups__site_group_status" to table: "site_groups"
CREATE INDEX "ix_site_groups__site_group_status" ON "sites"."site_groups" ("site_group_status");
-- Set comment to table: "site_groups"
COMMENT ON TABLE "sites"."site_groups" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "site_group_id" on table: "site_groups"
COMMENT ON COLUMN "sites"."site_groups"."site_group_id" IS 'Canonical identifier of the site group.';
-- Set comment to column: "site_group_code" on table: "site_groups"
COMMENT ON COLUMN "sites"."site_groups"."site_group_code" IS 'Stable internal code for the site group.';
-- Set comment to column: "site_group_name" on table: "site_groups"
COMMENT ON COLUMN "sites"."site_groups"."site_group_name" IS 'Human-readable name.';
-- Set comment to column: "business_label" on table: "site_groups"
COMMENT ON COLUMN "sites"."site_groups"."business_label" IS 'Business-facing label such as PROPERTY, CLUSTER, or CAMPUS.';
-- Set comment to column: "description" on table: "site_groups"
COMMENT ON COLUMN "sites"."site_groups"."description" IS 'Description of the site group.';
-- Set comment to column: "operator_entity_name" on table: "site_groups"
COMMENT ON COLUMN "sites"."site_groups"."operator_entity_name" IS 'Parking operator or business entity name, where applicable.';
-- Set comment to column: "timezone_name" on table: "site_groups"
COMMENT ON COLUMN "sites"."site_groups"."timezone_name" IS 'IANA time zone used for local operational interpretation.';
-- Set comment to column: "default_currency_code" on table: "site_groups"
COMMENT ON COLUMN "sites"."site_groups"."default_currency_code" IS 'Default currency for the site group.';
-- Set comment to column: "site_group_status" on table: "site_groups"
COMMENT ON COLUMN "sites"."site_groups"."site_group_status" IS 'Site group lifecycle status.';
-- Set comment to column: "public_lookup_enabled" on table: "site_groups"
COMMENT ON COLUMN "sites"."site_groups"."public_lookup_enabled" IS 'Indicates whether public Web Pay lookup is enabled for this site group.';
-- Set comment to column: "default_payment_enabled" on table: "site_groups"
COMMENT ON COLUMN "sites"."site_groups"."default_payment_enabled" IS 'Indicates whether payment flow is enabled by default.';
-- Set comment to column: "effective_from" on table: "site_groups"
COMMENT ON COLUMN "sites"."site_groups"."effective_from" IS 'Start of site group effectiveness.';
-- Set comment to column: "effective_to" on table: "site_groups"
COMMENT ON COLUMN "sites"."site_groups"."effective_to" IS 'End of site group effectiveness.';
-- Set comment to column: "created_at" on table: "site_groups"
COMMENT ON COLUMN "sites"."site_groups"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "site_groups"
COMMENT ON COLUMN "sites"."site_groups"."created_by_user_id" IS 'User who created the site group.';
-- Set comment to column: "created_by_service_identity_id" on table: "site_groups"
COMMENT ON COLUMN "sites"."site_groups"."created_by_service_identity_id" IS 'Service identity that created the site group.';
-- Set comment to column: "updated_at" on table: "site_groups"
COMMENT ON COLUMN "sites"."site_groups"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "site_groups"
COMMENT ON COLUMN "sites"."site_groups"."updated_by_user_id" IS 'User who last updated the site group.';
-- Set comment to column: "updated_by_service_identity_id" on table: "site_groups"
COMMENT ON COLUMN "sites"."site_groups"."updated_by_service_identity_id" IS 'Service identity that last updated the site group.';
-- Set comment to column: "row_version" on table: "site_groups"
COMMENT ON COLUMN "sites"."site_groups"."row_version" IS 'Optimistic concurrency version.';
-- Create "sites" table
CREATE TABLE "sites"."sites" (
  "site_id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "site_group_id" uuid NOT NULL,
  "site_code" character varying(64) NOT NULL,
  "site_name" character varying(128) NOT NULL,
  "site_description" text NULL,
  "site_type" "sites"."site_type_enum" NOT NULL,
  "timezone_name" character varying(64) NOT NULL,
  "address_line1" character varying(256) NULL,
  "address_line2" character varying(256) NULL,
  "city" character varying(128) NULL,
  "province" character varying(128) NULL,
  "country_code" character(2) NOT NULL,
  "lgu_code" character varying(32) NULL,
  "site_status" "sites"."site_status_enum" NOT NULL,
  "public_lookup_enabled" boolean NOT NULL DEFAULT false,
  "payment_enabled" boolean NOT NULL DEFAULT false,
  "effective_from" timestamptz NOT NULL,
  "effective_to" timestamptz NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "created_by_user_id" uuid NULL,
  "created_by_service_identity_id" uuid NULL,
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  "updated_by_user_id" uuid NULL,
  "updated_by_service_identity_id" uuid NULL,
  "row_version" bigint NOT NULL DEFAULT 1,
  CONSTRAINT "pk_sites" PRIMARY KEY ("site_id"),
  CONSTRAINT "uq_sites__site_group_site_code" UNIQUE ("site_group_id", "site_code")
);
-- Create index "ix_sites__site_group_id" to table: "sites"
CREATE INDEX "ix_sites__site_group_id" ON "sites"."sites" ("site_group_id");
-- Create index "ix_sites__site_status" to table: "sites"
CREATE INDEX "ix_sites__site_status" ON "sites"."sites" ("site_status");
-- Set comment to table: "sites"
COMMENT ON TABLE "sites"."sites" IS 'ExitPass v1.2 table generated from Section 13 physical table specifications.';
-- Set comment to column: "site_id" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."site_id" IS 'Canonical identifier of the site.';
-- Set comment to column: "site_group_id" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."site_group_id" IS 'Parent site group.';
-- Set comment to column: "site_code" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."site_code" IS 'Stable internal site code.';
-- Set comment to column: "site_name" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."site_name" IS 'Human-readable site name.';
-- Set comment to column: "site_description" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."site_description" IS 'Site description.';
-- Set comment to column: "site_type" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."site_type" IS 'Site type or operational classification.';
-- Set comment to column: "timezone_name" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."timezone_name" IS 'IANA time zone used for the site.';
-- Set comment to column: "address_line1" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."address_line1" IS 'Address line 1.';
-- Set comment to column: "address_line2" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."address_line2" IS 'Address line 2.';
-- Set comment to column: "city" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."city" IS 'City or municipality.';
-- Set comment to column: "province" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."province" IS 'Province or region.';
-- Set comment to column: "country_code" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."country_code" IS 'Country code.';
-- Set comment to column: "lgu_code" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."lgu_code" IS 'LGU or jurisdiction code for statutory discount policy applicability.';
-- Set comment to column: "site_status" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."site_status" IS 'Site lifecycle status.';
-- Set comment to column: "public_lookup_enabled" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."public_lookup_enabled" IS 'Indicates whether public lookup is enabled at site level.';
-- Set comment to column: "payment_enabled" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."payment_enabled" IS 'Indicates whether payment flow is enabled at site level.';
-- Set comment to column: "effective_from" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."effective_from" IS 'Start of site effectiveness.';
-- Set comment to column: "effective_to" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."effective_to" IS 'End of site effectiveness.';
-- Set comment to column: "created_at" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."created_at" IS 'Record creation timestamp.';
-- Set comment to column: "created_by_user_id" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."created_by_user_id" IS 'User who created the site.';
-- Set comment to column: "created_by_service_identity_id" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."created_by_service_identity_id" IS 'Service identity that created the site.';
-- Set comment to column: "updated_at" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."updated_at" IS 'Last update timestamp.';
-- Set comment to column: "updated_by_user_id" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."updated_by_user_id" IS 'User who last updated the site.';
-- Set comment to column: "updated_by_service_identity_id" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."updated_by_service_identity_id" IS 'Service identity that last updated the site.';
-- Set comment to column: "row_version" on table: "sites"
COMMENT ON COLUMN "sites"."sites"."row_version" IS 'Optimistic concurrency version.';

