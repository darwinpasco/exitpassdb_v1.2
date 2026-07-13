CREATE INDEX IF NOT EXISTS ix_policy_import_review_decisions__review
    ON operator_console.production_policy_import_review_decisions (review_id, decided_at);;

