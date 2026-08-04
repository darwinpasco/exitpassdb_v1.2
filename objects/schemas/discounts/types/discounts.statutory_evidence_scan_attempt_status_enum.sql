CREATE TYPE "discounts"."statutory_evidence_scan_attempt_status_enum" AS ENUM (
  'PENDING',
  'CLAIMED',
  'IN_PROGRESS',
  'RETRY_PENDING',
  'COMPLETED',
  'FAILED_TERMINAL',
  'STALE_REJECTED',
  'CANCELLED'
);;
