-- Create index "ix_vendor_payment_ack__payment_confirmation_id" to table: "vendor_payment_acknowledgments"
CREATE INDEX "ix_vendor_payment_ack__payment_confirmation_id" ON "integration"."vendor_payment_acknowledgments" ("payment_confirmation_id");;

