-- Set comment to column: "provider_session_id" on table: "provider_callbacks"
COMMENT ON COLUMN "payments"."provider_callbacks"."provider_session_id" IS 'Provider session correlated to the callback, where known.';;

