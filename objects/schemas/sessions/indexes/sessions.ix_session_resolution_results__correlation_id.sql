-- Create index "ix_session_resolution_results__correlation_id" to table: "session_resolution_results"
CREATE INDEX "ix_session_resolution_results__correlation_id" ON "sessions"."session_resolution_results" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

