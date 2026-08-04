CREATE TYPE "discounts"."statutory_evidence_validation_status_enum" AS ENUM (
  'NOT_STARTED',
  'PENDING',
  'IN_PROGRESS',
  'PASSED',
  'FAILED',
  'RETRY_PENDING',
  'UNAVAILABLE',
  'UNSUPPORTED',
  'UNKNOWN'
);;
