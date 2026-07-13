-- Create enum type "audit_change_type_enum"
CREATE TYPE "audit"."audit_change_type_enum" AS ENUM ('CREATE', 'UPDATE', 'DELETE', 'ACTIVATE', 'SUSPEND', 'REVOKE', 'RETIRE', 'APPROVE', 'REJECT', 'CONFIGURE', 'ROTATE_CREDENTIAL_REFERENCE', 'CORRECT', 'MIGRATE');;

