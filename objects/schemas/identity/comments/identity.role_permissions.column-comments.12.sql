-- Set comment to column: "revoked_by_service_identity_id" on table: "role_permissions"
COMMENT ON COLUMN "identity"."role_permissions"."revoked_by_service_identity_id" IS 'Service identity that revoked the binding.';;

