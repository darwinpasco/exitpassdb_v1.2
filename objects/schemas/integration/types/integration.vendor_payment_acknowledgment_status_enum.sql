-- Create enum type "vendor_payment_acknowledgment_status_enum"
CREATE TYPE "integration"."vendor_payment_acknowledgment_status_enum" AS ENUM ('PENDING', 'CONFIRMED', 'FAILED', 'SKIPPED_DISABLED', 'RETRY_PENDING', 'CANCELLED');;

