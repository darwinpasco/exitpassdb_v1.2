CREATE TYPE "discounts"."statutory_evidence_deletion_status_enum" AS ENUM (
  'NOT_REQUESTED',
  'REQUESTED',
  'IN_PROGRESS',
  'DELETED',
  'FAILED',
  'BLOCKED_BY_HOLD',
  'OBJECT_MISSING'
);;
