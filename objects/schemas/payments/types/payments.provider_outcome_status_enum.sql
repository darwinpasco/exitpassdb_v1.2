-- Create enum type "provider_outcome_status_enum"
CREATE TYPE "payments"."provider_outcome_status_enum" AS ENUM ('CONFIRMED', 'FAILED', 'EXPIRED', 'CANCELLED', 'REJECTED', 'UNKNOWN');;

