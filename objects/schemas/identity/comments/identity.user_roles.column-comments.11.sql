-- Set comment to column: "revoked_by_user_id" on table: "user_roles"
COMMENT ON COLUMN "identity"."user_roles"."revoked_by_user_id" IS 'User who revoked the assignment.';;

