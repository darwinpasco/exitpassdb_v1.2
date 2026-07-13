-- Create enum type "policy_resolution_basis_enum"
CREATE TYPE "discounts"."policy_resolution_basis_enum" AS ENUM ('LOCAL_ORDINANCE_APPLIED', 'NATIONAL_LAW_FALLBACK', 'SITE_POLICY_OPERATIONAL_ONLY', 'MANUAL_POLICY_SELECTION', 'SYSTEM_DEFAULT');;

