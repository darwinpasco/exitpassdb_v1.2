-- Create index "ix_reconciliation_items__payment_attempt_id" to table: "reconciliation_items"
CREATE INDEX "ix_reconciliation_items__payment_attempt_id" ON "reconciliation"."reconciliation_items" ("payment_attempt_id");;

