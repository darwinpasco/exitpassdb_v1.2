-- Create enum type "reconciliation_run_status_enum"
CREATE TYPE "reconciliation"."reconciliation_run_status_enum" AS ENUM ('STARTED', 'PROCESSING', 'COMPLETED', 'FAILED', 'CANCELLED', 'REPROCESSING');;

