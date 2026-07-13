-- Create enum type "payment_attempt_status_enum"
CREATE TYPE "core"."payment_attempt_status_enum" AS ENUM ('REQUESTED', 'PENDING_PROVIDER', 'PENDING_FINALIZATION', 'CONFIRMED', 'FAILED', 'EXPIRED', 'CANCELLED');;

