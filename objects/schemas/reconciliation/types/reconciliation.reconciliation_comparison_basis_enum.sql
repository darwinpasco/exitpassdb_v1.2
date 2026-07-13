-- Create enum type "reconciliation_comparison_basis_enum"
CREATE TYPE "reconciliation"."reconciliation_comparison_basis_enum" AS ENUM ('MOPS_TO_CORE', 'MOPS_TO_SETTLEMENT', 'PROVIDER_TO_CORE', 'MANUAL_GATE_TO_CORE', 'COUPON_WALLET_TO_APPLICATION', 'SETTLEMENT_TO_CONFIRMATION', 'INCIDENT_SCOPE_REVIEW');;

