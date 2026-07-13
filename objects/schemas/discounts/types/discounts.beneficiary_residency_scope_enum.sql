-- Create enum type "beneficiary_residency_scope_enum"
CREATE TYPE "discounts"."beneficiary_residency_scope_enum" AS ENUM ('RESIDENT_ONLY', 'NON_RESIDENT_ALLOWED', 'MIXED_OR_CONFLICTING', 'UNVERIFIED', 'NOT_APPLICABLE');;

