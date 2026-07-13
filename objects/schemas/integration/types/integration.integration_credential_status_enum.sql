-- Create enum type "integration_credential_status_enum"
CREATE TYPE "integration"."integration_credential_status_enum" AS ENUM ('DRAFT', 'ACTIVE', 'ROTATION_DUE', 'EXPIRED', 'REVOKED', 'RETIRED');;

