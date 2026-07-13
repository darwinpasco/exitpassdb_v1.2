-- Create index "ix_session_lookup_cache__correlation_id" to table: "session_lookup_cache"
CREATE INDEX "ix_session_lookup_cache__correlation_id" ON "sessions"."session_lookup_cache" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

