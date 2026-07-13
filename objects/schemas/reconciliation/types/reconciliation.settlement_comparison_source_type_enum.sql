-- Create enum type "settlement_comparison_source_type_enum"
CREATE TYPE "reconciliation"."settlement_comparison_source_type_enum" AS ENUM ('PROVIDER_SETTLEMENT_REPORT', 'BANK_STATEMENT', 'PAYMENT_RAIL_REPORT', 'MERCHANT_WALLET_LEDGER', 'MOPS_EXPORT', 'MANUAL_COLLECTION_REPORT', 'OTHER');;

