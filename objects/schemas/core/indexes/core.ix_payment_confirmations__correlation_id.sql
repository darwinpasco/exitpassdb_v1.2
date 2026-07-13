-- Create index "ix_payment_confirmations__correlation_id" to table: "payment_confirmations"
CREATE INDEX "ix_payment_confirmations__correlation_id" ON "core"."payment_confirmations" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

