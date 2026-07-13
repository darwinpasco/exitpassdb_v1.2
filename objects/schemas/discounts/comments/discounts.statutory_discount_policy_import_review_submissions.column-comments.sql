-- Set comment to column: "dry_run_summary_json" on table: "statutory_discount_policy_import_review_submissions"
COMMENT ON COLUMN "discounts"."statutory_discount_policy_import_review_submissions"."dry_run_summary_json" IS 'Sanitized dry-run aggregate summary only; no raw CSV, raw evidence, personal data, secrets, or production credentials.';;

