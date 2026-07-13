-- Create enum type "provider_callback_processing_status_enum"
CREATE TYPE "payments"."provider_callback_processing_status_enum" AS ENUM ('RECEIVED', 'PROCESSING', 'PROCESSED', 'DUPLICATE', 'REJECTED', 'FAILED');;

