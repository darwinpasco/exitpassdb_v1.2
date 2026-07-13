-- Create enum type "policy_import_review_action_enum"
CREATE TYPE "discounts"."policy_import_review_action_enum" AS ENUM ('SUBMIT_FOR_REVIEW', 'REQUEST_CHANGES', 'APPROVE_LEGAL', 'APPROVE_OPS', 'APPROVE_QA', 'APPROVE_DB', 'REJECT', 'CANCEL', 'MARK_SUPERSEDED');;

