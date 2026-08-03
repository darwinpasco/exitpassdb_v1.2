CREATE TYPE "discounts"."statutory_evidence_retention_status_enum" AS ENUM (
  'POLICY_REQUIRED',
  'ACTIVE',
  'ELIGIBLE_FOR_DELETION',
  'HELD',
  'EXPIRED',
  'TOMBSTONED'
);;
