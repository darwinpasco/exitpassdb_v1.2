-- Set comment to column: "created_by_service_identity_id" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."created_by_service_identity_id" IS 'Service identity that wrote the security event.';;

