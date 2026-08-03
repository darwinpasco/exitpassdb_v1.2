CREATE TYPE "discounts"."statutory_evidence_upload_status_enum" AS ENUM (
  'NOT_AUTHORIZED',
  'AUTHORIZED',
  'UPLOADING',
  'UPLOADED',
  'FAILED',
  'EXPIRED',
  'CANCELLED'
);;
