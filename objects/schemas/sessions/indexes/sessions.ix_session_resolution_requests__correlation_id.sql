-- Create index "ix_session_resolution_requests__correlation_id" to table: "session_resolution_requests"
CREATE INDEX "ix_session_resolution_requests__correlation_id" ON "sessions"."session_resolution_requests" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

