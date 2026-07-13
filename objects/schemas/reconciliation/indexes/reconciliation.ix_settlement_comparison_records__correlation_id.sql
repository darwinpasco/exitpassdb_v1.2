-- Create index "ix_settlement_comparison_records__correlation_id" to table: "settlement_comparison_records"
CREATE INDEX "ix_settlement_comparison_records__correlation_id" ON "reconciliation"."settlement_comparison_records" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

