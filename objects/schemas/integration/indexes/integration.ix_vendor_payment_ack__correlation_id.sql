-- Create index "ix_vendor_payment_ack__correlation_id" to table: "vendor_payment_acknowledgments"
CREATE INDEX "ix_vendor_payment_ack__correlation_id" ON "integration"."vendor_payment_acknowledgments" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

