CREATE UNIQUE INDEX IF NOT EXISTS ux_policy_import_review_submissions__active_fingerprint
    ON operator_console.production_policy_import_review_submissions (maker_operator_id, submission_fingerprint)
    WHERE review_status NOT IN ('REJECTED', 'CANCELLED', 'SUPERSEDED');;

