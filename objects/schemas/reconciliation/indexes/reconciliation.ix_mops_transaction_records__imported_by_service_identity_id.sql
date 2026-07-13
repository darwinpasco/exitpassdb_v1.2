-- Create index "ix_mops_transaction_records__imported_by_service_identity_id" to table: "mops_transaction_records"
CREATE INDEX "ix_mops_transaction_records__imported_by_service_identity_id" ON "reconciliation"."mops_transaction_records" ("imported_by_service_identity_id");;

