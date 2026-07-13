-- Create enum type "policy_import_review_row_decision_enum"
CREATE TYPE "discounts"."policy_import_review_row_decision_enum" AS ENUM ('IMPORTABLE_AFTER_APPROVAL', 'MANUAL_REVIEW_REQUIRED', 'NOT_IMPORTABLE', 'DRY_RUN_ONLY', 'DUPLICATE_IN_FILE');;

