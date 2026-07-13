-- Set comment to column: "created_by_service_identity_id" on table: "audit_events"
COMMENT ON COLUMN "audit"."audit_events"."created_by_service_identity_id" IS 'Service identity that wrote the audit event.';;

