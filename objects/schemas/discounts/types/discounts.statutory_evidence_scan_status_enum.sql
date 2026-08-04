CREATE TYPE "discounts"."statutory_evidence_scan_status_enum" AS ENUM (
  'NOT_STARTED',
  'PENDING',
  'IN_PROGRESS',
  'PASSED',
  'CLEAN',
  'FAILED',
  'MALICIOUS',
  'SUSPICIOUS',
  'ERROR_RETRYABLE',
  'ERROR_TERMINAL',
  'UNAVAILABLE',
  'TIMEOUT',
  'UNKNOWN'
);;
