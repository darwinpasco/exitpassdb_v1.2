CREATE INDEX IF NOT EXISTS ix_policy_import_review_findings__review
    ON operator_console.production_policy_import_review_findings (review_id, created_at);;

