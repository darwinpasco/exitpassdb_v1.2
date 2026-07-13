-- Set comment to column: "idempotency_key" on table: "session_resolution_requests"
COMMENT ON COLUMN "sessions"."session_resolution_requests"."idempotency_key" IS 'Idempotency key for repeated lookup request, where used.';;

