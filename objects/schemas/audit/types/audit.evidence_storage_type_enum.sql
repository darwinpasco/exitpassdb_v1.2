-- Create enum type "evidence_storage_type_enum"
CREATE TYPE "audit"."evidence_storage_type_enum" AS ENUM ('OBJECT_STORAGE', 'EVIDENCE_VAULT', 'HASH_ONLY', 'EXTERNAL_REFERENCE', 'REDACTED_REFERENCE');;

