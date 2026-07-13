-- Create enum type "evidence_capture_status_enum"
CREATE TYPE "discounts"."evidence_capture_status_enum" AS ENUM ('CAPTURED', 'REFERENCED', 'REDACTED', 'PURGED', 'HASH_ONLY', 'REJECTED');;

