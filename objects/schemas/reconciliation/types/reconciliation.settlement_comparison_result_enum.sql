-- Create enum type "settlement_comparison_result_enum"
CREATE TYPE "reconciliation"."settlement_comparison_result_enum" AS ENUM ('MATCHED', 'MISMATCHED', 'SHORT_SETTLED', 'OVER_SETTLED', 'MISSING_SETTLEMENT', 'DUPLICATE_SETTLEMENT', 'UNRESOLVED', 'REJECTED');;

