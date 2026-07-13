-- Set comment to column: "expires_at" on table: "session_resolution_requests"
COMMENT ON COLUMN "sessions"."session_resolution_requests"."expires_at" IS 'Request expiry timestamp where lookup has a bounded validity window.';;

