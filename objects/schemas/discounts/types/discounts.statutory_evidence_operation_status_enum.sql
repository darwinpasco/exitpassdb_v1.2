CREATE TYPE "discounts"."statutory_evidence_operation_status_enum" AS ENUM (
  'ACCEPTED',
  'IDEMPOTENT_REPLAY',
  'SEMANTIC_CONFLICT',
  'REJECTED'
);;
