-- Create index "ix_user_roles__assigned_by_user_id" to table: "user_roles"
CREATE INDEX "ix_user_roles__assigned_by_user_id" ON "identity"."user_roles" ("assigned_by_user_id");;

