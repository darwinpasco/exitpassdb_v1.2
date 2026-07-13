-- Create enum type "security_event_result_enum"
CREATE TYPE "audit"."security_event_result_enum" AS ENUM ('ALLOWED', 'DENIED', 'FAILED', 'BLOCKED', 'REJECTED', 'DETECTED', 'ESCALATED', 'UNKNOWN');;

