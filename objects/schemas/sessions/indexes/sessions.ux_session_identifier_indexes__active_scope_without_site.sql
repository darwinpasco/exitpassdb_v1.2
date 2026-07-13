-- Create index "ux_session_identifier_indexes__active_scope_without_site" to table: "session_identifier_indexes"
CREATE UNIQUE INDEX "ux_session_identifier_indexes__active_scope_without_site" ON "sessions"."session_identifier_indexes" ("site_group_id", "identifier_type", "identifier_hash") WHERE ((identifier_status = 'ACTIVE'::sessions.session_identifier_status_enum) AND (site_id IS NULL));;

