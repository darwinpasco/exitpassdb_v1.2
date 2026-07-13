-- Create enum type "central_pms_report_status_enum"
CREATE TYPE "payments"."central_pms_report_status_enum" AS ENUM ('NOT_REPORTED', 'REPORTED', 'ACCEPTED', 'REJECTED', 'FAILED', 'RETRY_PENDING');;

