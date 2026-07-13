-- Create index "ux_user_roles__active_user_role" to table: "user_roles"
CREATE UNIQUE INDEX "ux_user_roles__active_user_role" ON "identity"."user_roles" ("user_id", "role_id") WHERE (assignment_status = 'ACTIVE'::identity.user_role_assignment_status_enum);;

