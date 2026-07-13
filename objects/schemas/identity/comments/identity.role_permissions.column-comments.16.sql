-- Set comment to column: "created_by_service_identity_id" on table: "role_permissions"
COMMENT ON COLUMN "identity"."role_permissions"."created_by_service_identity_id" IS 'Service identity that created the binding.';;

