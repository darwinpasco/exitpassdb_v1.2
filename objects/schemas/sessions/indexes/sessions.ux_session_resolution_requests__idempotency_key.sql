-- Create index "ux_session_resolution_requests__idempotency_key" to table: "session_resolution_requests"
CREATE UNIQUE INDEX "ux_session_resolution_requests__idempotency_key" ON "sessions"."session_resolution_requests" ("idempotency_key") WHERE (idempotency_key IS NOT NULL);;

