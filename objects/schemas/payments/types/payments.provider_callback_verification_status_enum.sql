-- Create enum type "provider_callback_verification_status_enum"
CREATE TYPE "payments"."provider_callback_verification_status_enum" AS ENUM ('UNVERIFIED', 'VERIFIED', 'FAILED_SIGNATURE', 'FAILED_TIMESTAMP', 'FAILED_SOURCE', 'FAILED_REPLAY', 'FAILED_SCHEMA', 'UNKNOWN');;

