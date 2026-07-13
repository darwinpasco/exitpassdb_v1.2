-- Create enum type "reconciliation_exception_status_enum"
CREATE TYPE "reconciliation"."reconciliation_exception_status_enum" AS ENUM ('OPEN', 'ASSIGNED', 'UNDER_REVIEW', 'RESOLVED', 'REJECTED', 'ESCALATED', 'CLOSED', 'CANCELLED');;

