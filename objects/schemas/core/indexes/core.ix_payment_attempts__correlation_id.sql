-- Create index "ix_payment_attempts__correlation_id" to table: "payment_attempts"
CREATE INDEX "ix_payment_attempts__correlation_id" ON "core"."payment_attempts" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

