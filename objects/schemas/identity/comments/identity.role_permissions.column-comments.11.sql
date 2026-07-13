-- Set comment to column: "revoked_by_user_id" on table: "role_permissions"
COMMENT ON COLUMN "identity"."role_permissions"."revoked_by_user_id" IS 'User who revoked the binding.';;

