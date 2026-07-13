-- Create enum type "policy_verification_status_enum"
CREATE TYPE "discounts"."policy_verification_status_enum" AS ENUM ('LEAD_UNVERIFIED', 'VERIFIED_SECONDARY', 'VERIFIED_OFFICIAL', 'APPROVED_FOR_PILOT', 'ACTIVE_APPROVED', 'PROPOSED_ONLY', 'REJECTED');;

