-- Create index "ux_exit_authorizations__active_by_session" to table: "exit_authorizations"
CREATE UNIQUE INDEX "ux_exit_authorizations__active_by_session" ON "core"."exit_authorizations" ("parking_session_id") WHERE (authorization_status = 'ISSUED'::core.exit_authorization_status_enum);;

