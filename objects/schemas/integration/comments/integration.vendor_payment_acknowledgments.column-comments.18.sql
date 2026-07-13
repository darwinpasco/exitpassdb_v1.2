-- Set comment to column: "idempotency_key" on table: "vendor_payment_acknowledgments"
COMMENT ON COLUMN "integration"."vendor_payment_acknowledgments"."idempotency_key" IS 'Optional idempotency key for acknowledgment creation or later workflow execution.';;

