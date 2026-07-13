-- Create index "ix_role_permissions__assigned_by_user_id" to table: "role_permissions"
CREATE INDEX "ix_role_permissions__assigned_by_user_id" ON "identity"."role_permissions" ("assigned_by_user_id");;

