CREATE TYPE "discounts"."statutory_evidence_set_status_enum" AS ENUM (
  'OPEN',
  'LOCKED_FOR_REVIEW',
  'BOUND',
  'REVIEW_COMPLETED',
  'TOMBSTONED'
);;
