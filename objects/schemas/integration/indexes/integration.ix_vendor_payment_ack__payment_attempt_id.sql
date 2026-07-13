-- Create index "ix_vendor_payment_ack__payment_attempt_id" to table: "vendor_payment_acknowledgments"
CREATE INDEX "ix_vendor_payment_ack__payment_attempt_id" ON "integration"."vendor_payment_acknowledgments" ("payment_attempt_id");;

