-- Create index "ix_mops_transaction_records__correlation_id" to table: "mops_transaction_records"
CREATE INDEX "ix_mops_transaction_records__correlation_id" ON "reconciliation"."mops_transaction_records" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

