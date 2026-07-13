-- Create enum type "policy_import_review_status_enum"
CREATE TYPE "discounts"."policy_import_review_status_enum" AS ENUM ('DRAFT_DRY_RUN', 'SUBMITTED_FOR_REVIEW', 'LEGAL_REVIEW_PENDING', 'OPS_REVIEW_PENDING', 'QA_REVIEW_PENDING', 'DB_REVIEW_PENDING', 'APPROVED_FOR_DB_REPO_ALIGNMENT', 'REJECTED', 'CANCELLED', 'SUPERSEDED');;

