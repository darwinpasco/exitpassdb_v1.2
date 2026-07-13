-- Create enum type "mops_transaction_record_status_enum"
CREATE TYPE "reconciliation"."mops_transaction_record_status_enum" AS ENUM ('RECORDED', 'IMPORTED', 'PENDING_RECONCILIATION', 'RECONCILED', 'DISPUTED', 'REJECTED', 'CANCELLED');;

