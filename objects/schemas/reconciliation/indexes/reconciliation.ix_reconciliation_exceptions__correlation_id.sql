-- Create index "ix_reconciliation_exceptions__correlation_id" to table: "reconciliation_exceptions"
CREATE INDEX "ix_reconciliation_exceptions__correlation_id" ON "reconciliation"."reconciliation_exceptions" ("correlation_id") WHERE (correlation_id IS NOT NULL);;

