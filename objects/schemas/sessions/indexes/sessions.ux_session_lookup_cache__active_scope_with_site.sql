-- Create index "ux_session_lookup_cache__active_scope_with_site" to table: "session_lookup_cache"
CREATE UNIQUE INDEX "ux_session_lookup_cache__active_scope_with_site" ON "sessions"."session_lookup_cache" ("site_group_id", "site_id", "lookup_type", "lookup_identifier_hash") WHERE ((cache_status = 'ACTIVE'::sessions.session_lookup_cache_status_enum) AND (site_id IS NOT NULL));;

