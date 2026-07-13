-- Create index "ix_reconciliation_items__correlation_id" to table: "reconciliation_items"
CREATE INDEX "ix_reconciliation_items__correlation_id" ON "reconciliation"."reconciliation_items" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

