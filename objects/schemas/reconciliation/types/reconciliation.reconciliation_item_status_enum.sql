-- Create enum type "reconciliation_item_status_enum"
CREATE TYPE "reconciliation"."reconciliation_item_status_enum" AS ENUM ('PENDING', 'MATCHED', 'MISMATCHED', 'EXCEPTION', 'DISPUTED', 'REJECTED', 'RESOLVED', 'CLOSED');;

