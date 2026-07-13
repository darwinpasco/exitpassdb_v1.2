-- Create index "ux_mops_transaction_records__source_batch_collection" to table: "mops_transaction_records"
CREATE UNIQUE INDEX "ux_mops_transaction_records__source_batch_collection" ON "reconciliation"."mops_transaction_records" ("source_system_code", "source_batch_ref", "collection_reference") WHERE ((source_batch_ref IS NOT NULL) AND (collection_reference IS NOT NULL));;

