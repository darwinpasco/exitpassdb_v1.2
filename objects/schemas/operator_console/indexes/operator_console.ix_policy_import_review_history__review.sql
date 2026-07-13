CREATE INDEX IF NOT EXISTS ix_policy_import_review_history__review
    ON operator_console.production_policy_import_review_history (review_id, occurred_at);;

