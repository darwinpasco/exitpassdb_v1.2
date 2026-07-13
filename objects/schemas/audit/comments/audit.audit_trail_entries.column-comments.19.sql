-- Set comment to column: "created_by_service_identity_id" on table: "audit_trail_entries"
COMMENT ON COLUMN "audit"."audit_trail_entries"."created_by_service_identity_id" IS 'Service identity that wrote the audit trail entry.';;

