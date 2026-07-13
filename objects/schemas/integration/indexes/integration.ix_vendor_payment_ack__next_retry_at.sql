-- Create index "ix_vendor_payment_ack__next_retry_at" to table: "vendor_payment_acknowledgments"
CREATE INDEX "ix_vendor_payment_ack__next_retry_at" ON "integration"."vendor_payment_acknowledgments" ("next_retry_at") WHERE (next_retry_at IS NOT NULL);;

