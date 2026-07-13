-- Create enum type "evidence_redaction_status_enum"
CREATE TYPE "audit"."evidence_redaction_status_enum" AS ENUM ('NOT_REDACTED', 'PARTIALLY_REDACTED', 'FULLY_REDACTED', 'HASH_ONLY');;

