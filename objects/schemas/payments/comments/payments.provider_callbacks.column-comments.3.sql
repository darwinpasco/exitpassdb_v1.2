-- Set comment to column: "payment_attempt_id" on table: "provider_callbacks"
COMMENT ON COLUMN "payments"."provider_callbacks"."payment_attempt_id" IS 'Payment attempt correlated to the callback, where known.';;

