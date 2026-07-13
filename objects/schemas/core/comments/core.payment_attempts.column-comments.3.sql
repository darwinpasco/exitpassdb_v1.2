-- Set comment to column: "idempotency_key" on table: "payment_attempts"
COMMENT ON COLUMN "core"."payment_attempts"."idempotency_key" IS 'Client or service-supplied idempotency key.';;

