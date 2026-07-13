CREATE INDEX IF NOT EXISTS ix_policy_import_review_submissions__status
    ON operator_console.production_policy_import_review_submissions (review_status, updated_at DESC);;

