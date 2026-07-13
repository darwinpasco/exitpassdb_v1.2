-- Create index "ix_reconciliation_runs__correlation_id" to table: "reconciliation_runs"
CREATE INDEX "ix_reconciliation_runs__correlation_id" ON "reconciliation"."reconciliation_runs" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

