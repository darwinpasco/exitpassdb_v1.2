-- Set comment to column: "payload_hash" on table: "provider_callbacks"
COMMENT ON COLUMN "payments"."provider_callbacks"."payload_hash" IS 'SHA-256 hash of raw callback payload.';;

