-- Create enum type "provider_session_status_enum"
CREATE TYPE "payments"."provider_session_status_enum" AS ENUM ('CREATED', 'ACTIVE', 'PENDING', 'PAID', 'FAILED', 'EXPIRED', 'CANCELLED', 'UNKNOWN');;

