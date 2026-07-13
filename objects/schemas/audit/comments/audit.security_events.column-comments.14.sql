-- Set comment to column: "request_fingerprint_hash" on table: "security_events"
COMMENT ON COLUMN "audit"."security_events"."request_fingerprint_hash" IS 'Hash of request fingerprint where retained.';;

