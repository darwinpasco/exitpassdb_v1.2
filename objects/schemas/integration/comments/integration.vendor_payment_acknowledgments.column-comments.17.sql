-- Set comment to column: "next_retry_at" on table: "vendor_payment_acknowledgments"
COMMENT ON COLUMN "integration"."vendor_payment_acknowledgments"."next_retry_at" IS 'Next scheduled retry timestamp, when retry is pending.';;

