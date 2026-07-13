-- Set comment to column: "parking_session_id" on table: "session_resolution_results"
COMMENT ON COLUMN "sessions"."session_resolution_results"."parking_session_id" IS 'Canonical parking session created or reused after deterministic match.';;

