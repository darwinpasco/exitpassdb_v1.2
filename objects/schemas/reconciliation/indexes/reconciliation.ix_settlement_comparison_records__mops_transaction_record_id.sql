-- Create index "ix_settlement_comparison_records__mops_transaction_record_id" to table: "settlement_comparison_records"
CREATE INDEX "ix_settlement_comparison_records__mops_transaction_record_id" ON "reconciliation"."settlement_comparison_records" ("mops_transaction_record_id");;

