-- Create index "ux_role_permissions__active_role_permission" to table: "role_permissions"
CREATE UNIQUE INDEX "ux_role_permissions__active_role_permission" ON "identity"."role_permissions" ("role_id", "permission_id") WHERE (binding_status = 'ACTIVE'::identity.role_permission_binding_status_enum);;

