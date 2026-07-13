-- Create index "ix_vendor_payment_ack__acknowledgment_status" to table: "vendor_payment_acknowledgments"
CREATE INDEX "ix_vendor_payment_ack__acknowledgment_status" ON "integration"."vendor_payment_acknowledgments" ("acknowledgment_status");;

