-- Set comment to column: "rate_limit_key_hash" on table: "session_resolution_requests"
COMMENT ON COLUMN "sessions"."session_resolution_requests"."rate_limit_key_hash" IS 'Hashed rate-limit key where lookup throttling applies.';;

