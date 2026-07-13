-- Create index "ux_mops_transaction_records__source_transaction_ref" to table: "mops_transaction_records"
CREATE UNIQUE INDEX "ux_mops_transaction_records__source_transaction_ref" ON "reconciliation"."mops_transaction_records" ("source_system_code", "source_transaction_ref") WHERE (source_transaction_ref IS NOT NULL);;

