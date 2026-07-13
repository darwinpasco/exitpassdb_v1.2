-- Set comment to column: "revoked_by_service_identity_id" on table: "user_roles"
COMMENT ON COLUMN "identity"."user_roles"."revoked_by_service_identity_id" IS 'Service identity that revoked the assignment.';;

