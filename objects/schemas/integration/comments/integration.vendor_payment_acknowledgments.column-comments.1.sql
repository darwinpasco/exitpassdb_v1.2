-- Set comment to column: "payment_attempt_id" on table: "vendor_payment_acknowledgments"
COMMENT ON COLUMN "integration"."vendor_payment_acknowledgments"."payment_attempt_id" IS 'ExitPass payment attempt whose finality caused this acknowledgment record.';;

