-- Create index "ix_settlement_comparison_records__payment_confirmation_id" to table: "settlement_comparison_records"
CREATE INDEX "ix_settlement_comparison_records__payment_confirmation_id" ON "reconciliation"."settlement_comparison_records" ("payment_confirmation_id");;

