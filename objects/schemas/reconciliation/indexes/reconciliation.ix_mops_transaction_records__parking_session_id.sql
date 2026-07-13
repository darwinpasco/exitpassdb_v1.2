-- Create index "ix_mops_transaction_records__parking_session_id" to table: "mops_transaction_records"
CREATE INDEX "ix_mops_transaction_records__parking_session_id" ON "reconciliation"."mops_transaction_records" ("parking_session_id");;

