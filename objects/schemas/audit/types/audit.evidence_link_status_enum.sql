-- Create enum type "evidence_link_status_enum"
CREATE TYPE "audit"."evidence_link_status_enum" AS ENUM ('ACTIVE', 'REDACTED', 'PURGED', 'HASH_ONLY', 'REVOKED');;

