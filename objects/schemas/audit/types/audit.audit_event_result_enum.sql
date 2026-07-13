-- Create enum type "audit_event_result_enum"
CREATE TYPE "audit"."audit_event_result_enum" AS ENUM ('SUCCESS', 'FAILED', 'DENIED', 'REJECTED', 'EXPIRED', 'CANCELLED', 'DUPLICATE', 'NO_OP', 'UNKNOWN');;

