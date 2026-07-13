-- Create enum type "statutory_discount_validations_status_enum"
CREATE TYPE "discounts"."statutory_discount_validations_status_enum" AS ENUM ('REQUESTED', 'PENDING_OPERATOR_REVIEW', 'APPROVED', 'REJECTED', 'FAILED', 'EXPIRED', 'CANCELLED');;

