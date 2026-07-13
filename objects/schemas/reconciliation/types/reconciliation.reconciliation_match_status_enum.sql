-- Create enum type "reconciliation_match_status_enum"
CREATE TYPE "reconciliation"."reconciliation_match_status_enum" AS ENUM ('NOT_EVALUATED', 'MATCH', 'AMOUNT_MISMATCH', 'MISSING_SOURCE', 'MISSING_TARGET', 'DUPLICATE', 'INCONCLUSIVE', 'REJECTED');;

