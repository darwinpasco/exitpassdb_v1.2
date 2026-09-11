-- Create enum type "role_provenance_enum"
CREATE TYPE "identity"."role_provenance_enum" AS ENUM (
  'CANONICAL_ROLE',
  'HISTORICAL_LEGACY_ROLE',
  'UAT_TEST_ROLE',
  'SERVICE_ROLE'
);;
